{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>

<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/CustomView/CustomView.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/advancefilter.js?v={$GLOBALMINVERSION}"></script>

<form action="index.php" method="post" name="form" id="form" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="EditMultiApproveList"/>
    <input type="hidden" name="blockid" value="{$BLOCKID}"/>
    <input type="hidden" name="record" value="{$RECORD}"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>

    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td style="text-align: right;">
                <input type="button"  onclick="getEditApproveForm('',{$RECORD},{$BLOCKID},'','','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');" class="saveauto b_radius3" name="editapprove" value="{'EDIT'|@getFixedLabel}"/> 
                {*zkt 20220425 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】*}
                <input type="button" class="saveauto b_radius3" onclick="forceApproveRetStart({$BLOCKID},{$RECORD});" name="submitapprove" value="{'FORCEDREJECTSUBMITAPPROVAL'|@getFixedLabel}"/>
            </td>
        </tr>
    </table>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="4">
                {'PROCESSINFO'|@getFixedLabel}        
            </th>
        </tr>
        <tr>
            <td width="20%" align="right">
                {'PROCESSNAME'|@getFixedLabel}  
            </td>
            <td width="30%">
                {$APPROVE.0.name}
             </td>
            <td width="20%" align="right">
                {'WHETHERTOENABLE'|@getFixedLabel}
            </td>
            <td width="30%">
                {if $APPROVE.0.status eq 0}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
        </tr>
        <tr>
            <td width="20%" align="right">
                {'APPROVEFINISHEDALLOWEDIT'|@getFixedLabel}  
            </td>
            <td width="30%">
                {if $APPROVE.0.finishedallowedit eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>

            <td width="20%" align="right" {if $again_submit eq 'yes' && $APPROVE.0.finishedallowedit eq 'yes'}{else} style="display:none"{/if} >
                {'ApproveAllowAgainSubmit'|@getFixedLabel}
            </td>
            <td width="30%" {if $again_submit eq 'yes' && $APPROVE.0.finishedallowedit eq 'yes'}{else} style="display:none"{/if}>
                {if $APPROVE.0.allowagainsubmit eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
        </tr>
        {*editor:gyq_132 reason:审批流程默认值改进  2019/7/22 13:56 ID1000479*}
        <tr>
            <td width="20%" align="right">
                {'WHETHERTOALLOWANTIAPPROVALOFDATA'|@getFixedLabel}
            </td>
            <td width="30%">
                {if $APPROVE.0.allowantiapproval eq 1}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
            <td width="20%" align="right">
                {'APPROVEDEFAULTVALUEONNEW'|@getFixedLabel}
            </td>
            <td width="30%">
                {if $APPROVE.0.default_on_new eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
        </tr>
        <tr>
            <td width="20%" align="right">
                {'APPROVEDEFAULTVALUEONSUBMIT'|@getFixedLabel}
            </td>
            <td width="30%">
                {if $APPROVE.0.default_on_submit eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
            {*ls 2021-08-11  【ID1001881】航港：加急（优先）审批(查看审批流程详情显示)*}
            <td width="20%" align="right">
                {'ShowUrgentWhenSubmit'|@getFixedLabel}
            </td>
            <td width="30%">
                {if $APPROVE.0.showurgent eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
        </tr>

        <tr>
            {*详情页增加提交意见字段显示 *}
            <td width="20%" align="right">
                {'APPROVEDEFAULTVALUEONPURPORT'|@getFixedLabel}
            </td>
            <td width="30%">
                {if $APPROVE.0.showsubmitremark eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
            {if $APPROVE.0.showsubmitremark eq 'yes'}
            <td width="20%" align="right">
                {'APPROVEDEFAULTVALUEONPURPORTREQUIRE'|@getFixedLabel}
            </td>
            <td width="30%">
                {if $APPROVE.0.submitremarkrequire eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
            {/if}
        </tr>
        <tr>
            <td width="20%" align="right">
                {'Enableexpeditingfunction'|@getFixedLabel}
            </td>
            <td width="30%">
                {if $APPROVE.0.enableexpediting eq 'yes'}
                    {'YES'|@getFixedLabel}
                {else}
                    {'NO'|@getFixedLabel}
                {/if}
            </td>
        </tr>
        <tr>
            <td width="20%" align="right">
                {'REMARK'|@getFixedLabel}
            </td>
            <td colspan="3" width="80%">
                {$APPROVE.0.description}
            </td>
        </tr>
    </table>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="4">
                {'APPLICABLESCOPE'|@getFixedLabel}<font class="greyFont9">({'DOCSELECTROLEAPPROVAL'|@getFixedLabel})</font>
            </th>
        </tr>
        <tr>
            <td width="20%" align="right">
                {'APPLICABLESCOPE'|@getFixedLabel}  
            </td>
            <td colspan="3">
                {$APPROVE.1}
             </td>
        </tr>
    </table>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th>
                {'APPROVALSTEP'|@getFixedLabel}
            </th>
            <th style="text-align: right;">
                <input class="createauto b_radius3 inputBornone" type="button" {if $ISUSED eq 'yes'} style="display:none"{/if} onclick="getCreateApproveStepForm('{$RECORD}','',{$BLOCKID},'','','create','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');" name="newstep" value="{'ADDAPPROVALSTEP'|@getFixedLabel}"/>
            </th>
        </tr>
    </table>
    <div id="approvestepdetaillist" style="overflow: auto;">
        {include file='Approve/EditMultiApproveEntries.tpl'}
    </div>
    <div class="listRloesHelp" style="padding: 0px 10px 20px;">
        <font color="red">{'TIPS'|@getFixedLabel}:</font>
        <ul>
        <li>1. {'MODULECANMULAPPROVAL'|@getFixedLabel}</li>
        <li>2. {'USERMORETHANAPPROVALPRO'|@getFixedLabel}</li>
        <li>3. {'NOAPPROVALUSERPROCESS'|@getFixedLabel}</li>
        </ul>
   </div>
</form>

<div id="approvestep" class="D_pop_box LdPopWidth800px" style="display:none;">

</div>

{*editor : gyq_05  reason : 接收弹框内容  date:2016 2 26*}
<div id="divSendInform" class="D_pop_box LdPopWidth600px" style="display:none;">
    <div id="divSendInform_div" ></div>
</div>

<div id="divSendInform_content" class="D_pop_box LdPopWidth900px" style="display:none;z-index:100000;">
    <div id="divSendInform_content_div"></div>
</div>
<script type="text/javascript">

// var popupobj=new CrmPopup();
//  popupobj.type="DetailApprovePage";
//  CrmPopup.global_listPopupObj.push(popupobj);
</script>