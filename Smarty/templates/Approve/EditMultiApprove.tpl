{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
{*editor:gyq_05 reason:新增加载以下文件实现选择部门或用户时的弹框 date:2016 2 25*}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Approve/Approve.js?v={$GLOBALMINVERSION}"></script>

<div>
  <form action="index.php" method="post" name="form" id="form">
        <input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="action" value="SaveMultiApprove"/>
        <input type="hidden" name="record" value="{$RECORD}"/>
        <input type="hidden" name="blockid" value="{$BLOCKID}"/>
        <input type="hidden" name="mode" value="{$MODE}"/>
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
        <input type="hidden" id="approve_allocate_type" name="action_type" value="EditMultiApprove"/>

        <table class="settingPopTable lasttdbordernon nowhitespace" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tr>
              <th colspan="4">{'BASICINFO'|@getFixedLabel}</th>
          </tr>
          <tr>
              <td width="20%" align="right">
              <font color="red">*</font>
              {'PROCESSNAME'|@getFixedLabel}  
              </td>
              <td width="25%" align="left"><input id="name" name="name" type="text"  class="commonTextBoxPop" value="{$APPROVE.0.name}"/> </td>
              <td width="25%" align="right">
              {'WHETHERTOENABLE'|@getFixedLabel}  
              </td>
              <td width="30%" align="left">
                  <input columnname="status" onclick="changeApproveStatus(this,'{$APPROVE[0].id}','{$APPROVE[0].tabid}')" name="status" class="second_switch" type="checkbox" {if $APPROVE.0.status eq 0}checked{/if} />
              </td>
          </tr>
            {if $editprofile neq 'no'}
          <tr>
            <td align="right">
            {'APPROVEFINISHEDALLOWEDIT'|@getFixedLabel}  
            </td>
            <td align="left">
                <input name="finishedallowedit" onclick="CheckfinishedalloweditChange()" class="second_switch" type="checkbox" {if $APPROVE.0.finishedallowedit eq 'yes'}checked{/if} /> 
            </td>
              {*模块的again_submit勾选后，选项“审批结束编辑单据保存，自动提交审批时默认审批流程”才会显示*}
            <input type="hidden" name="again_submit_status" value="{$AGAIN_SUBMIT}">
            <td align="right">
                {'ApproveAllowAgainSubmit'|@getFixedLabel}
            </td>
            <td align="left">
                <input name="allowagainsubmit" class="second_switch" type="checkbox" {if $APPROVE.0.allowagainsubmit eq 'yes'}checked{/if} />
            </td>
          </tr>
            {/if}
          <tr>
                <td align="right">
                    {'WHETHERTOALLOWANTIAPPROVALOFDATA'|@getFixedLabel}
                </td>
                <td align="left">
                    <input name="allowantiapproval" class="second_switch" type="checkbox" {if $APPROVE.0.allowantiapproval eq 1 ||$RECORD<=0}checked{/if} />
                </td>
              <td align="right">
                  {'APPROVEDEFAULTVALUEONNEW'|@getFixedLabel}
              </td>
              <td align="left">
                  <input name="default_on_new" class="second_switch" type="checkbox" {if $APPROVE.0.default_on_new eq 'yes'}checked{/if} />
              </td>
          </tr>
          {*editor:gyq_132 reason:审批流程默认值改进  2019/7/22 13:56 ID1000479*}
          <tr>
              <td align="right">
                  {'APPROVEDEFAULTVALUEONSUBMIT'|@getFixedLabel}
              </td>
              <td align="left">
                  <input name="default_on_submit" class="second_switch" type="checkbox" {if $APPROVE.0.default_on_submit eq 'yes'}checked{/if} />
              </td>
              {*ls 2021-08-11  【ID1001881】航港：加急（优先）审批*}
              <td align="right">
                  {'ShowUrgentWhenSubmit'|@getFixedLabel}
              </td>
              <td align="left">
                  <input name="showurgent" class="second_switch" type="checkbox" {if $APPROVE.0.showurgent eq 'yes'}checked{/if} />
              </td>
          </tr>
          <tr>
              <!--新加编辑页面两个审批字段位置-->
              <td align="right">
                  {'APPROVEDEFAULTVALUEONPURPORT'|@getFixedLabel}
              </td>
              <td align="left">
                  <input name="showsubmitremark" onclick="ChecksubmitremarkChange()" class="second_switch" type="checkbox" {if $APPROVE.0.showsubmitremark eq 'yes'}checked{/if} />
              </td>
              <td align="right" id="td_require">
                  {'APPROVEDEFAULTVALUEONPURPORTREQUIRE'|@getFixedLabel}
              </td>
              <td align="left">
                  <input name="submitremarkrequire" class="second_switch" type="checkbox" {if $APPROVE.0.submitremarkrequire eq 'yes'}checked{/if} />
              </td>

          </tr>
          <tr>
              {*"是否启用催审功能"参数*}
              <td align="right">
                  {'Enableexpeditingfunction'|@getFixedLabel}
              </td>
              <td align="left">
                  <input name="enableexpediting" class="second_switch" type="checkbox" {if $APPROVE.0.enableexpediting eq 'yes'}checked{/if} />
              </td>
              <td  align="right"  tag="editresettag" >
                  {'EDITDOCUMENTRESETTHEAPPROVAL'|@getFixedLabel}
              </td>
              <td align="left">
                  <input name="editresetapprove" tag="editresettag" class="second_switch" type="checkbox" {if $APPROVE.0.editresetapprove neq 'no'}checked{/if} />
              </td>
          </tr> 

          <tr>
              <td align="right">{'REMARK'|@getFixedLabel}</td>
              <td colspan="3" align="left">
                <textarea  class="commonSelect" name="description" style="height: auto;margin: 5px 0 4px;">{$APPROVE.0.description}</textarea>
              </td>
          </tr>
           <tr tag="tr_FinishedApproveAllowEditFieldSet"  {if $APPROVE.0.finishedallowedit neq 'yes'} style="display:none"{/if}>
            <th colspan="4" class="f1"><strong>{'FinishedApproveAllowEditFieldSet'|@getFixedLabel}</strong></th>
          </tr>
          <tr tag="tr_FinishedApproveAllowEditFieldSet" {if $APPROVE.0.finishedallowedit neq 'yes'} style="display:none"{/if}>
              <td colspan="4"> <input type="radio" name="fininsedselectfieldtype" value="all" {if  $fininsedselectfieldtype eq 'all'} checked=""{/if} id="fininsedselectfieldtype_all" /><label for="fininsedselectfieldtype_all">{"AllFields"|@getFixedLabel}</label>
                  <input type="radio" name="fininsedselectfieldtype" value='part' {if  $fininsedselectfieldtype eq 'part'} checked=""{/if}/ id="fininsedselectfieldtype_part"> <label for="fininsedselectfieldtype_part">{"PartialFields"|@getFixedLabel}</label></td>
          </tr>
          <tr  name='tr_FinishedApproveAllowEditFieldSet' {if $APPROVE.0.finishedallowedit neq 'yes' ||$fininsedselectfieldtype eq 'all'} style="display:none"{/if}>
              <td colspan="4">

                <table class="settingPopTable lasttdbordernon" width="100%" cellspacing="0" cellpadding="0" border="0">
                    <tbody><tr>
                		<td class="padTB10" width="355">
                			<b>{'OPTIONALFIELD'|@getFixedLabel}</b><br>
                			<input class="detailedViewTextBox" style="width:100%;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'AssmablyList',event)" tag="请输入要查找的字段" placeholder="请输入要查找的字段" name="allmember"><br>
                			<select style="height: 180px;width:100%;margin-top: 10px;" class="commonMultipleSelect" name="AssmablyList" id="AssmablyList" ondblclick="addColumnCustomviewModule('AssmablyList','selectedAssmablyColumns')" multiple="">
                                  {foreach item=tmplabel name=loop key=tmpcolumns from=$finisedallfield_arr}
                                    <option value="{$tmpcolumns}">{$tmplabel}</option>
                                    {/foreach}

                            </select>
                		</td>
                		<td width="45" style="text-align: center;">
                			<a class="icon-newhomearr icon-mright" href="javascript:;" onclick="copySelectedOptionsCustomviewModule('AssmablyList','selectedAssmablyColumns');" title="右移"></a><br>
                			<a class="icon-newhomearr icon-mleft" style="margin-top:15px;" href="javascript:;" onclick="copySelectedOptionsCustomviewModule('selectedAssmablyColumns','AssmablyList');" title="左移"></a>
                		</td>
                		<td class="padTB10" width="355">
                			<b>{'Selected_Fields'|@getFixedLabel}</b><br><br><br>
                			<select size="11" style="height: 180px;width:100%;margin-top: 10px;" class="commonMultipleSelect" name="selectedAssmablyColumns" id="selectedAssmablyColumns" ondblclick="addColumnCustomviewModule('selectedAssmablyColumns','AssmablyList')" multiple="">

                                    {foreach item=tmplabel name=loop key=tmpcolumns from=$havechoosefield_arr}
                                    <option value="{$tmpcolumns}">{$tmplabel}</option>
                                    {/foreach}
                            </select>
                		</td>
                		<td width="45" style="text-align: center;">
                			<a class="icon-newhomearr icon-mup" href="javascript:;" onclick="ProductDetailmoveUp();" title="上移"></a><br>
                			<a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" onclick="ProductDetailmoveDown();" title="下移"></a>
                		</td>
                    </tr>
                </tbody></table>
              </td>
          </tr>
          <tr tag="tr_FinishedApproveAllowEditFieldSet" {if $APPROVE.0.finishedallowedit neq 'yes'} style="display:none"{/if}>
                <td>{'SetAllowEidtFieldScope'|@getFixedLabel}</td>
              <td colspan="3"  class="select-input" width="80%" align="left">
                <input type="radio" name="finishededittype" value="all" id="finishededittype_all" {if $APPROVE.0.finishedfield_allocatetype eq 'all'} checked=""{/if}><label for="finishededittype_all" class="padR10">{'ALLTHEUSERS'|@getFixedLabel} </label>
                <input type="radio" name="finishededittype" value="group" id="finishededittype_group" {if $APPROVE.0.finishedfield_allocatetype eq 'group'} checked=""{/if}><label for="finishededittype_group" class="padR10">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
                <input type="radio" name="finishededittype" value="user" id="finishededittype_user" {if $APPROVE.0.finishedfield_allocatetype eq 'user'} checked=""{/if}><label for="finishededittype_user" class="padR10">{'SETBYUSERS'|@getFixedLabel}</label>
                <input type="radio" name="finishededittype" value="role" id="finishededittype_role" {if $APPROVE.0.finishedfield_allocatetype eq 'role'} checked=""{/if}><label for="finishededittype_role" >{'SetByRole'|@getFixedLabel}</label>
                <input type="hidden" id="selectfinishededitid" name="selectfinishededitid" class="templateprintuser" value="{$APPROVE.0.finishedfield_allocateid}">
                <input type="hidden" id="selectfinishededittype" name="selectfinishededittype" class="templateprintuser" value="{$APPROVE.0.finishedfield_allocatetype} ">
              </td>
          </tr>
          <tr>
            <th colspan="4" class="f1">{'APPLICABLESCOPE'|@getFixedLabel}</th>
          </tr>
          <tr>
              <td align="right">{'APPLICABLESCOPE'|@getFixedLabel}</td>
              <td colspan="3" width="80%" align="left" id="allocate_divcontent" class="select-input"></td>
          </tr>
        </table>
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tr>
            <th>{'APPROVALSTEP'|@getFixedLabel}</th>
            <th><div style="float:right;">
            <input class="createauto" type="button" {if $ISUSED eq 'yes'} style="display:none"{/if} onclick="getCreateApproveStepForm('{$RECORD}','',{$BLOCKID},'','','create','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');" name="newstep" value="{'ADDAPPROVALSTEP'|@getFixedLabel}"/>
          </div></th>
          </tr>
        </table>
        <div id="approvestepdetaillist" style="overflow: auto;">
          {include file="Approve/EditMultiApproveEntries.tpl"}
        </div>
	</form>
</div>

<script type="text/javascript">
var  record='{$RECORD}';
var popupobj=new CrmPopup();
popupobj.type="EditMultiApprove";
CrmPopup.global_listPopupObj.push(popupobj);

   
</script>