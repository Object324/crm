{literal}
<style type="text/css">
.pad{
	padding-left:10px;
}
.select2-container{
    display:inline;
}
.select2-container .select2-selection--multiple{
    height:36px;
    min-width:150px;
}
.select2-container--default .select2-selection--multiple .select2-selection__choice{
  margin: 3px;
}
.select2-container--open .select2-dropdown--below{
  width: 150px !important;
}
.select2-container {
  position: relative !important;
  top: 0px !important;
  left: 8px !important; 
}
</style>

{/literal}
<script>
  var fLabels = new Array();
  fLabels['e'] = '{'EQ'|@getFixedLabel}';
  fLabels['n'] = '{'NEQ'|@getFixedLabel}';
  fLabels['c'] = '{'IN'|@getFixedLabel}';
  fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
  fLabels['l'] = '{'LT'|@getFixedLabel}';
  fLabels['g'] = '{'GT'|@getFixedLabel}';
  fLabels['m'] = '{'LE'|@getFixedLabel}';;
  fLabels['h'] = '{'GE'|@getFixedLabel}';
  fLabels['bw'] = '{'Interval'|@getFixedLabel}';
  fLabels['b'] = '{'Before'|@getFixedLabel}';
  fLabels['a'] = '{'After'|@getFixedLabel}';
  fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
  fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
  var tmpstr='{$DATETIMESTR}';
  var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
</script>
<script src="{$JSURL}include/js/SystemPopup/PopupUsers.js"></script>
<script src="{$JSURL}include/js/modules/Settings/AccountSet.js"></script>
<form name="EditView" action="index.php" method="post" class="ajax_form" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="SaveAccountSet"/>
<input type="hidden" name="return_module" value="Settings"/>
<input type="hidden" name="return_action" value="AccountSet"/>
<input type="hidden" name="selectedcolumnsforadmin" value="{$ADMINACCOUNT}"/>
<input type="hidden" name="isset" value="{$ISET}"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<input type="hidden" name="account_set_advft_criteria"/>
<input type="hidden" name="account_set_advft_criteria_groups"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_ACCOUNT_SET'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <a href="javascript:;" onclick="AccountSet.save()" class="pg-btn-blue dinline-block lfloat" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</a>
            {if 'oem_crm'|@getCommonVersion eq 'no'}
              <a href="javascript:;" class="pg-btn-blue dinline-block lfloat" onclick="getLinksUrl('','Settings','publicAccountSet');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
            {/if}
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="picklist_datas" class="cont_wrap clear_float pad10">
            <div class="PublicseaSet">
             <ul>
                <li class="PublicTitle">
                  {'PUBLICCUSTOMERSET'|@getFixedLabel}
                  <b id="askgreyHelp" style="margin: -4px 0 0 3px;cursor: pointer;" class="icon-homeimg icon-askgrey">
                  <span id="tip_info" style="width:500px;white-space: normal;">{'EXPLAIN'|@getFixedLabel}{'MAOHAO'|@getFixedLabel}{'PRESSCUSTOMER'|@getFixedLabel}<br />{'MAINFEATURES'|@getFixedLabel}{'MAOHAO'|@getFixedLabel}{'CUSTOMERSALESFULFILLED'|@getFixedLabel}
                  <br />
                  {'PUBLICCUSTOMERPRIVILEGEINCLUDE'|@getFixedLabel}</span></b>
                </li>
                <li>
                  <span class="pad">{'ACTIVATEPUBLICCUST'|@getFixedLabel}</span>
                  {if $ISET eq 1}
                      <input type="checkbox" class="inputBornone input-btn-align" name="status" onclick="publicStatusChange(this)" /> 
                  {else}
                      <input type="checkbox" class="inputBornone input-btn-align" name="status" onclick="publicStatusChange(this)" checked="checked"/> 
                  {/if}
                </li>
               
                <li>
                  <span class="pad">{'UNALLOCATECUSTOMERADMIN'|@getFixedLabel}</span>
                  {if $ISET eq 1}
                      <input type="checkbox" class="inputBornone input-btn-align" name="getProfile" onclick="getProfileChange(this)" value="1" disabled="true"/> 
                  {else}
                      {if $GETPROFILE eq 1}
                          <input type="checkbox" class="inputBornone input-btn-align" name="getProfile"  onclick="getProfileChange(this)" value="1"/> 
                      {else}
                           <input type="checkbox" class="inputBornone input-btn-align" name="getProfile" onclick="getProfileChange(this)" value="0" checked/> 
                      {/if}
                  {/if}
                </li> 
                 <li id="objtainaccountcontrolday" {if $GETPROFILE neq 1} style="display:none"{/if}>
                  <span class="pad"></span>
                  {$objtainaccountcontroldayshtml}
                </li> 
                 <li>
                    <span class="pad">{'NOConvertNormalPermitter'|@getFixedLabel}</span>
                    {if $ISET eq 1}
                          <input type="checkbox" class="inputBornone input-btn-align" name="normalconvertbuttonprofile" /> 
                      {else}
                          {if $NormalConvertButtonProfile eq 'yes'}
                                <input type="checkbox" class="inputBornone input-btn-align" name="normalconvertbuttonprofile"  checked /> 
                          {else}
                               <input type="checkbox" class="inputBornone input-btn-align" name="normalconvertbuttonprofile" /> 
                          {/if}
                      {/if}
                  
                </li>
                
                <li>
                  <span class="pad">{'CUSTOMERCONTROLPUBLIC'|@getFixedLabel}</span>
                   {if $ISET eq 1}
                      <input type="checkbox" class="inputBornone input-btn-align" name="dataProfile" onclick="dataProfileChange(this)" value="1" disabled="true"/> 
                   {else}
                  
                       {if $DATAPROFILE eq 1}
                           <input type="checkbox" class="inputBornone input-btn-align" name="dataProfile" onclick="dataProfileChange(this)" value="1" /> 
                       {else}
                          <input type="checkbox" class="inputBornone input-btn-align" name="dataProfile" onclick="dataProfileChange(this)" value="0" checked/> 
                       {/if}
                   {/if}
                </li>
                <li>
                 <span class="pad">{'WEHERTODISPLAYTHEPUBLICCUSTOMERES'|@getFixedLabel}</span>
                  {assign var=fldname value='wheathershow'}
                  <select id="wheathershow"  name="wheathershow" style="display:none">
                    {foreach key=key item=item from=$LISTBTNLABEL}
                      <option value="{$key}" {if $key == $wheathershow}selected{/if}>{$item}</option>
                    {/foreach}
                  </select>
                  <div name="dv_chzn_{$fldname}" id="{$fldname}_div" class="chzn-container chzn-container-single" style="position:absolute; margin-left:6px;margin-top:-4px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','SettingRightContent')">
                    <a style="width:138px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','SettingRightContent')" href="javascript:void(0)" tabindex="-1"
                       name="cmb_a_{$fldname}">
                     
					  <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 126px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}','SettingRightContent')" value="{$LISTBTNLABEL.$wheathershow}">
                      <div>
                        <b></b>
                      </div>
                    </a>
                    <div style=" left:-9000px;width: 138px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                     <ul class="chzn-results" name="cmb_ul_{$fldname}">
                        {foreach key=key item=item from=$LISTBTNLABEL}
                        {assign var="j" value=$j+1}   
                          <li  class="active-result" style="padding: 6px 7px;" name="dv_chzn_{$key}_wheathershow" onclick="cmb_liclick('{$key}','wheathershow','SettingRightContent')" onmouseover="cmb_limouseover(event,'wheathershow','SettingRightContent')"> {$item}</li>
                        {/foreach}
                        <li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                     </ul>
                    </div>
                  </div>
                </li>
                <!--yyx 2015-4-21 begin 控制面板公海参数设置里增加‘序时簿“新建”功能下拉按钮选项-->
                <li style="height:40px;">
                  <span class="pad">{'NEWBUTTONDROP-DOWNOPTIONS'|@getFixedLabel}</span>
                  {assign var=fldname value='newdropdownoption'}
                  <select id="newdropdownoption"  name="newdropdownoption" style="display:none">
                    {foreach key=key item=item from=$buttonarray}  {*$buttonarray为公海参数值数组*}
                      <option value="{$key}" {if $key == $buttontype}selected{/if}>{$item}</option>
                    {/foreach}
                  </select>
                  <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="display:none;position:absolute; margin-left:6px;margin-top:-2px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','SettingRightContent')">
                    <a style="width:108px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','SettingRightContent')" href="javascript:void(0)" tabindex="-1"
                       name="cmb_a_{$fldname}">
                      <span name="cmb_span_optiontext_{$fldname}">{$buttonarray.$buttontype}</span>
                      <div>
                          <b></b>
                      </div>
                    </a>
                    <div style=" left:-9000px;width: 108px; top: 20px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                    <div class="chzn-search">
                    <input class="search_bg" type="text" autocomplete="off" style="width: 96px;" tabindex="0"  name='txt_search_{$fldname}' onclick="com_chosen(event,'{$fldname}','SettingRightContent')" onKeyUp="com_chosen(event,'{$fldname}','SettingRightContent')">
                    </div>
                     <ul class="chzn-results" name="cmb_ul_{$fldname}">
                        {foreach key=key item=item from=$buttonarray}
                        {assign var="i" value=$i+1}   
                          <li  class="active-result" style="padding: 6px 7px;" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','SettingRightContent')" onmouseover="cmb_limouseover(event,'{$fldname}','SettingRightContent')"> {$item}</li>
                        {/foreach}
                        <li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                     </ul>
                    </div>
                  </div>
                  <div style="position: absolute;display: inline;padding-left:8px;margin-top: -8px;height:10px" id="dv_{$fldname}">
                    <select  multiple id="m_{$fldname}" name="m_{$fldname}[]">    
                      {foreach key=key item=item from=$buttonarray}
                      {assign var=m_selected value=''}
                        {foreach item=sel_type from=$buttontype}
                          {if $key eq $sel_type}
                            {assign var=m_selected value='selected'}
                          {/if}
                        {/foreach}
                        <option value="{$key}" {$m_selected}>{$item}</option>
                      {/foreach}
                    </select>
                    <script type="text/javascript">
                        ld(document).ready(function() {ldelim}
                      
                            ld("#m_{$fldname}").select2({ldelim}closeOnSelect: false,dropdownParent: ld("#dv_newdropdownoption"){rdelim});
                        {rdelim}); 
                    </script>
                  </div>
                </li>
                <!--快速创建客户默认的客户公海状态-->
                <li>
                  <span class="pad">{'quicklycreatedefaultaccount'|@getFixedLabel}</span>
                  {assign var=fldname value='publicaccount'}
                  <select id="publicaccount"  name="publicaccount" style="display:none">
                    {foreach key=key item=item from=$publicaccountarray}
                      <option value="{$key}" {if $key == $publicaccount}selected{/if}>{$item}</option>
                    {/foreach}
                  </select>
                  <div name="dv_chzn_{$fldname}" id="{$fldname}_div" class="chzn-container chzn-container-single" style="position:absolute; margin-left:6px;margin-top:-4px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','SettingRightContent')">
                    <a style="width:108px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','SettingRightContent')" href="javascript:void(0)" tabindex="-1"
                       name="cmb_a_{$fldname}">
                     
					   <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 96px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_publicaccount' onclick="cmb_picklist_end_foucs(event,'publicaccount')" onKeyUp="com_chosen(event,'publicaccount','SettingRightContent')" value="{$publicaccountarray.$publicaccount}">
                      <div>
                        <b></b>
                      </div>
                    </a>
                    <div style=" left:-9000px;width: 108px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                     <ul class="chzn-results" name="cmb_ul_{$fldname}">
                        {foreach key=key item=item from=$publicaccountarray}
                          <li  class="active-result" style="padding: 6px 7px;" name="dv_chzn_{$key}_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','SettingRightContent')" onmouseover="cmb_limouseover(event,'{$fldname}','SettingRightContent')"> {$item}</li>
                        {/foreach}
                        <li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                     </ul>
                    </div>
                  </div>
                </li>
                <li>
                  <span class="pad">
                      {'AFTERCONVERTINGMODIFYTHEOWNER'|@getFixedLabel}
                      <div style="position: absolute;display: inline;">
                        <input fieldonly='' type="hidden" tabindex="" name="userid" id ="userid" value="{$userid}" />
                        <!-- <input type="text" id="user_name" class="btn-radius-system marTminus_3" name="user_name" value="{$user_name}"/> -->
                        <div class="btn-radius-system marTminus_3 lfloat" id="user_name" name="user_name" style="width:150px;line-height: 30px;padding-left: 8px;background: #fff;">{$user_name}</div>
                        <a class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="select_accountuser()" id="select_user_name"></a>
                        <a class="icon-homeimg icon-clear lfloat marT2" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_user()" id="clear_user_name"></a>
                      </div>  
                  </span>
                </li>
                <li>
                  <span class="pad">
                    {'AFTERRELEASINGTHEALLOCATEDHIGNSEAS'|@getFixedLabel}
                    <div style="position: absolute;display: inline;">
                      <input fieldonly='' type="hidden" tabindex="" name="allotuserid" id ="allotuserid" value="{$allotuser_id}" />
                      <!-- <input type="text" id="allotuser_name" class="btn-radius-system marTminus_3" name="allotuser_name" value="{$allotuser_name}"/> -->
                      <div class="btn-radius-system marTminus_3 lfloat" id="allotuser_name" name="allotuser_name" style="width:150px;line-height: 30px;padding-left: 8px;background: #fff;">{$allotuser_name}</div>
                      <a class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="select_allotuser()" id="select_allotuser_name"></a>
                      <a class="icon-homeimg icon-clear lfloat marT2" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_publicaccount()" id="clear_allotuser_name"></a>
                    </div>
                  </span>
                </li>
             </ul>
            </div>
            <div class="PublicseaSet" style="margin-top:-1px;">
              <ul>
                <li class="PublicTitle">{'AUTOMATICRECOVERYRULE'|@getFixedLabel}</li>   
                <li>
                  <span class="pad">1、<input type="checkbox" id="completeopt_checkbox" checked disabled="" />&nbsp;{"COMPLETEAUTOMATICRECOVERYRULE"|@getFixedLabel} 
                    <select name="completeopt"  class="btn-radius-system input-btn-align" onchange="changeCompleteopt(this,'completeopt')">
                      {if $COMPLETECONDITION eq 'and '}
                          <option value="and" selected>{"SEARCHAND"|@getFixedLabel}</option>
                      {else}
                      <option value="and" >{"SEARCHAND"|@getFixedLabel}</option>
                      {/if}
                      {if $COMPLETECONDITION eq 'or'}
                           <option value="or" selected="">{"OR"|@getFixedLabel}</option>
                      {else}
                          <option value="or">{"OR"|@getFixedLabel}</option>
                      {/if}
                    </select>
                  </span>
                  <span class="colorRed paddT10" id="completeopt_and" {if $COMPLETECONDITION eq 'or'}style="display:none;"{/if}>
                    {"alltherulesmustbedone"|@getFixedLabel}
                  </span>
                  <span class="colorRed paddT10" id="completeopt_or" {if $COMPLETECONDITION eq 'and' || $COMPLETECONDITION eq ''}style="display:none;"{/if}>
                    {"oneoftherulesmustbedone"|@getFixedLabel}
                  </span>
                  <ul>
                    {foreach from=$ARRCOMPLETECONDITION item=ruleinfo}
                    <li class="padli30">
                      <div class="publicDiv">{$ruleinfo.seqno}</div>
                      {if $ruleinfo.status eq 'active'}
                        <input type="checkbox" style="margin-top:-5px;" name="{$ruleinfo.tabname}_completechk" tag="chkcomplete_{$ruleinfo.seqno}" accounttype="chkcomplete" checked="" />
                      {else}
                        <input type="checkbox" style="margin-top:-5px;" name="{$ruleinfo.tabname}_completechk" tag="chkcomplete_{$ruleinfo.seqno}" accounttype="chkcomplete" />
                      {/if}
                      <select onchange="changerule('complete','{$ruleinfo.tabname}',this)" name="changerule_complete_{$ruleinfo.tabname}">
                        {if $ruleinfo.iscycle eq 'yes'}
                          <option value="no">{'SINGLERULE'|@getFixedLabel}</option>
                          <option value="yes" selected="">{'RECYCLERULE'|@getFixedLabel}</option>
                        {else}
                          <option value="no" selected="">{'SINGLERULE'|@getFixedLabel}</option>
                          <option value="yes" >{'RECYCLERULE'|@getFixedLabel}</option>
                        {/if}
                      </select>
                      <span name="complete_{$ruleinfo.tabname}_span_recycle"  {if $ruleinfo.iscycle eq 'no'} style="display:none"{/if}>
                        {$ruleinfo.recyclelabelbol1|@getFixedLabel}&nbsp;<input type="text" name="{$ruleinfo.tabname}_completedays" tag="complete_days" day_seqno="{$ruleinfo.seqno}"  class="btn-radius-system input-btn-align" style="width: 50px;text-align: center;" value="{$ruleinfo.days}"/>
                        {if $ruleinfo.recyclelabelbol2 neq ""}
                            {$ruleinfo.recyclelabelbol2|@getFixedLabel}{if $LANGUAGETYPE eq 'zh'}；{else};{/if}
                        {/if}
                      </span>
                      <span name="complete_{$ruleinfo.tabname}_span_single" {if $ruleinfo.iscycle eq 'yes'} style="display:none"{/if}>
                       {$ruleinfo.singlelabelbol1|@getFixedLabel}&nbsp;<input type="text" name="{$ruleinfo.tabname}_single_completedays" tag="complete_days" day_seqno="{$ruleinfo.seqno}"  class="btn-radius-system input-btn-align" style="width: 50px;text-align: center;" value="{$ruleinfo.days}"/>
                          {if $ruleinfo.singlelabelbol2 neq ""}
                              {$ruleinfo.singlelabelbol2|@getFixedLabel}{if $LANGUAGETYPE eq 'zh'}；{else};{/if}
                          {/if}
                      </span>
                    </li>
                    {/foreach}
                    <li class="paddT5">
                      <span class="pad">2、<input type="checkbox" id="chknormal_all_checkbox" {if $NORMALCHK eq 'yes'}checked{/if} />
                        {"NORMALCUSTOMRECYCLE"|@getFixedLabel}
                        <select  name="normalopt" class="btn-radius-system input-btn-align" onchange="changeCompleteopt(this,'normalopt')">
                          {if $NORMALCONDITION eq 'and '}
                              <option value="and" selected>{"SEARCHAND"|@getFixedLabel}</option>
                          {else}
                          <option value="and" >{"SEARCHAND"|@getFixedLabel}</option>
                          {/if}
                          {if $NORMALCONDITION eq 'or'}
                               <option value="or" selected="">{"OR"|@getFixedLabel}</option>
                          {else}
                              <option value="or">{"OR"|@getFixedLabel}</option>
                          {/if}
                        </select>
                      </span>
                      <span class="colorRed paddT10" id="normalopt_and" {if $NORMALCONDITION eq 'or'}style="display:none;"{/if}>
                        {"alltherulesmustbedone"|@getFixedLabel}
                      </span>
                      <span class="colorRed paddT10" id="normalopt_or" {if $NORMALCONDITION eq 'and' || $NORMALCONDITION eq ''}style="display:none;"{/if}>
                        {"oneoftherulesmustbedone"|@getFixedLabel}
                      </span>
                      <ul>
                        <div id="dvnormal">
                          {foreach from=$ARRNORMALCONDITION item=ruleinfo}
                          <li class="padli30">
                            <div class="publicDiv">{$ruleinfo.seqno}</div>
                            {if $ruleinfo.status eq 'active'}
                              <input type="checkbox" style="margin-top:-5px;" name="{$ruleinfo.tabname}_normalchk" tag="chknormal_{$ruleinfo.seqno}" onclick="normalchkClick()" accounttype="chknormal" checked="" />
                            {else}
                              <input type="checkbox" style="margin-top:-5px;" name="{$ruleinfo.tabname}_normalchk" tag="chknormal_{$ruleinfo.seqno}" onclick="normalchkClick()" accounttype="chknormal" />
                            {/if}
                            <select onchange="changerule('normal','{$ruleinfo.tabname}',this)" name="changerule_normal_{$ruleinfo.tabname}">
                                {if $ruleinfo.iscycle eq 'yes'}
                                    <option value="no">{'SINGLERULE'|@getFixedLabel}</option>
                                    <option value="yes" selected="">{'RECYCLERULE'|@getFixedLabel}</option>
                                {else}
                                    <option value="no" selected="">{'SINGLERULE'|@getFixedLabel}</option>
                                    <option value="yes" >{'RECYCLERULE'|@getFixedLabel}</option>
                                {/if}
                            </select>
                            <span name="normal_{$ruleinfo.tabname}_span_recycle"  {if $ruleinfo.iscycle eq 'no'} style="display:none"{/if} >
                                {$ruleinfo.recyclelabelbol1|@getFixedLabel}&nbsp;<input type="text" name="{$ruleinfo.tabname}_normaldays" tag="normal_days" day_seqno="{$ruleinfo.seqno}"  class="btn-radius-system input-btn-align" style="width: 50px;text-align: center;" value="{$ruleinfo.days}"/>
                                {if $ruleinfo.recyclelabelbol2 neq ""}
                                    {$ruleinfo.recyclelabelbol2|@getFixedLabel}{if $LANGUAGETYPE eq 'zh'}；{else};{/if}
                                {/if}
                            </span>
                            <span name="normal_{$ruleinfo.tabname}_span_single" {if $ruleinfo.iscycle eq 'yes'} style="display:none"{/if}>
                                {$ruleinfo.singlelabelbol1|@getFixedLabel}&nbsp;<input type="text" name="{$ruleinfo.tabname}_single_normaldays" tag="normal_days" day_seqno="{$ruleinfo.seqno}"  class="btn-radius-system input-btn-align" style="width: 50px;text-align: center;" value="{$ruleinfo.days}"/>
                                {if $ruleinfo.singlelabelbol2 neq ""}
                                    {$ruleinfo.singlelabelbol2|@getFixedLabel}{if $LANGUAGETYPE eq 'zh'}；{else};{/if}
                                {/if}
                            </span>
                          </li>
                          {/foreach}
                        </div>
                      </ul>
                    </li>
                  </ul>
                </li>
                <li style="margin-top: -25px;">
                  <span class="pad">3、{"BEFOREREMINDDAYSCUSTOMER"|@getFixedLabel}</span><input class="btn-radius-system input-btn-align"  name='beforereminddays' type="text" value="{$beforereminddays}"/>
                </li>
              </ul>   
            </div>
            <div class="PublicseaSet" style="margin-top:-1px;">
              <ul>
                <li class="PublicTitle">{'AUTORECYCLERULEDATACATEGORY'|@getFixedLabel}</li>   
              </ul>
              <div>
                {include file='AdvanceFilter.tpl' SOURCE='customview'}
              </div>
            </div>
            <div class="PublicseaSet" style="margin-top:-1px;">
              <ul>
                  <li class="PublicTitle">{'maximumnumberofhighseascustomers'|@getFixedLabel}</li>
                  <li class="paddT10" style="padding-left:10px;"><input type="radio" style="margin-top: -3px;" class="inputBornone" name="astricttype" id="radio_one_astricttype" {if $ASTRICTTYPE eq 1} checked="checked" {/if} value="1" onclick="changeastricttype('1','')"/>
                     {'Accordingtotheusercontrol'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'Eachuser'|@getFixedLabel}&nbsp;
                     <input id='select_user_ASTRICTTYPE' type="text"  class="btn-radius-system input-btn-align" {if $ASTRICTTYPE eq 2}disabled = true {/if} name="count" style="width:50px;text-align:center;" value="{$COUNT}"/>
                  </li>
                  <li style="padding-left:10px;">
                     <input type="radio" style="margin-top: -3px;" class="inputBornone" name="astricttype" {if $ASTRICTTYPE eq 2} checked="checked" {/if} value="2" onclick="changeastricttype('2',{if $COUNT eq ''}0{else}{$COUNT}{/if})"/> {'Accordingtotherolcontrol'|@getFixedLabel}
                  </li>
                  <!--li><span class="pad colorC0">{"EXPLAIN"|@getFixedLabel}：{'LIMITUSERPUBLICCUST'|@getFixedLabel}</span></li-->
                  <!--li><strong>{'USERMAXNUMCUSTOMER'|@getFixedLabel}</strong></li-->
                  <li  class="paddT10" id='select_role_ASTRICTTYPE' {if $ASTRICTTYPE eq 1}style="display:none;padding-left:10px;"{else}style="padding-left:10px;"{/if} >{$ROLETREE}</li>
              </ul>
            </div>
            <div class="PublicseaSet" style="margin-top:-1px;">
              <table width="100%" class="" cellspacing="0" cellpadding="0" border="0">
                <tr>
                  <td class="PublicTitle" width="100%" colspan="3">{'PUBLICUSERSET'|@getFixedLabel}</td>
                </tr>
                <tr>
                  <td colspan="3" class="pad paddT10">
                    <div id='view_scope' class="select-input">
                        <label><input type="radio" {if $USERSACCOUNT_TYPE eq 'all'}checked="" {/if} value="all" name="radioUser" onclick="CustomScope.setAllUser();">
                        <span class="padR10">{'ALLTHEUSERS'|@getFixedLabel}</span></label>
                        <label><input type="radio" {if $USERSACCOUNT_TYPE eq 'group'}checked="" {/if} undefined="" onclick="CustomScope.setScopeGroup('{$USERSACCOUNT}')" value="group" name="radioUser">
                        <span class="padR10">{'SETBYDEPARTMENT'|@getFixedLabel}</span></label>
                        <label><input type="radio" {if $USERSACCOUNT_TYPE eq 'user'}checked="" {/if} undefined="" onclick="CustomScope.setScopeUser('{$USERSACCOUNT}');" value="user" name="radioUser">
                        <span class="padR10">{'SETBYSHIYONGFANWEI'|@getFixedLabel}</span></label>
                      <input id="customscope_type" class="templateprintuser" type="hidden" value="{$USERSACCOUNT_TYPE}" name="customscope_type">
                      <input id="customscope_ids" class="templateprintuser" type="hidden" value="{$USERSACCOUNT}" name="customscope_ids">
                    </div>
                  </td>
                </tr>
                <tr>
                  <td colspan="3" class="pad paddT10">
                    <p class="colorC0">{'EXPLAIN'|@getFixedLabel}：{'USERSPUBLICCUSTOMER'|@getFixedLabel}</p>
                    <p class="colorRed paddT10">{'NOTE'|@getFixedLabel}：{'ADMINATUOPRIVLEGE'|@getFixedLabel}</p>
                  </td>
                </tr>
              </table>
              <table width="100%" class="" cellspacing="0" cellpadding="0" border="0">
                <tr>
                  <td class="PublicTitle" width="100%">{'SETPUBLICCUSTOMERADMIN'|@getFixedLabel}</td>
                </tr>
                <tr>
                  <td width="40%" class="pad paddT10">
                    <a href="javascript:void" onclick="choosepublicadmin()" title="{'CHOOSEPUBLICACCOUNTADMIN'|@getFixedLabel}" class="choosepublicadmin"> {'CHOOSEPUBLICACCOUNTADMIN'|@getFixedLabel}</a>
                  </td>
                </tr>
                <tr>
                   <td class="pad paddT10">
                     <p class="colorC0">{'EXPLAIN'|@getFixedLabel}：{'EXTENDPUBLICCUSTOMER'|@getFixedLabel}</p>
                     <p class="colorRed paddT10">{'NOTE'|@getFixedLabel}：{'ADMINATUOPRIVLEGE'|@getFixedLabel}</p>
                   </td>
                </tr>
              </table>
            </div>
        </div>
    </div>
</div>
</form>
<script type="text/javascript">
//publicStatusChange();//34493: 系统设置>公海参数设置>将：公海未分配客户不控制数据权限（可查询所有公海未分配客户）、公海成员客户序时簿“全部”页签是否显示公海客户>勾选上或者去掉点击保存：结果刚才的操作没有生效。
var userIdArr=new Array({$USERIDSTR});
var userNameArr=new Array({$USERNAMESTR});
var userIdArrUSER=new Array({$USERIDSTRUSERS});
var userNameArrUSER=new Array({$USERNAMESTRUSERS});
var userlabel='{'LBL_USERS'|@getFixedLabel}';
 var jsonrecoverymodules='{$ARRRECOVERYMODULES}';
   if(jsonrecoverymodules!=null&&jsonrecoverymodules!=undefined&&jsonrecoverymodules!='')
  {
       var recoverymodules=  eval('('+ jsonrecoverymodules +')')?eval('('+ jsonrecoverymodules +')'):JSON.parse(jsonrecoverymodules);
       
  }
//constructSelectOptions(userIdArr,userNameArr);//管理员赋值
//constructSelectOptionsUsers(userIdArrUSER,userNameArrUSER);//用户赋值下拉框
{literal}
//35400 公海参数设置界面“且”和“或”的说明
function changeCompleteopt(obj,fieldname){
	if(obj.value == 'and'){
		ld('#'+fieldname+'_and').show();
		ld('#'+fieldname+'_or').hide();
	}else{
		ld('#'+fieldname+'_and').hide();
		ld('#'+fieldname+'_or').show();
	}
}
//35401: 公海参数设置条件组前面应该有复选框
function normalchkClick(){
	var  normalchkonechoose=false;
	ld("[accounttype=chknormal]").each(function () {
		if(ld(this).is(":checked"))
		{
			normalchkonechoose=true;
			return false;
		}
	});
	if(normalchkonechoose){
		ld("#chknormal_all_checkbox").prop("checked",'true');
	}else{
		ld("#chknormal_all_checkbox").removeAttr("checked");
	}
}

function changerule(type,tabname,obj)
{
     var selectindex=obj.selectedIndex;
    var selectvalue=obj.options[selectindex].value;
    if(selectvalue=='yes')
    {
        var spanname=type+'_'+tabname+'_span_recycle';
        var hidespanname=type+'_'+tabname+'_span_single';
    }
    else
    {
        var spanname=type+'_'+tabname+'_span_single';
         var hidespanname=type+'_'+tabname+'_span_recycle';
    }
   
    ld("span[name="+spanname+"]").css("display","inline");
    ld("span[name="+hidespanname+"]").css("display","none"); 
}

{/literal}
function constructSelectOptions(idArr,nameArr){ldelim}
	var form=document.forms['EditView'];
	//var nowNamePrefix=userlabel+"::";
    var nowNamePrefix=userlabel;
	if(nameArr.length>0){ldelim}
		constructedOptionValue = idArr;
		constructedOptionName = nameArr;
		for(var i=0;i<constructedOptionName.length;i++){ldelim}
			//var nowName=userlabel+"::"+constructedOptionName[i];
            var nowName=constructedOptionName[i];
			var nowId=constructedOptionValue[i];
			form.AllUsersAdmin.options[i]=new Option(nowName,nowId);
		
		{rdelim}
	{rdelim}
	
{rdelim}
//用户赋值
function constructSelectOptionsUsers(idArr,nameArr){ldelim}
	var form=document.forms['EditView'];
	//var nowNamePrefix=userlabel+"::";
	var nowNamePrefix=userlabel;
	if(nameArr.length>0){ldelim}
		constructedOptionValue = idArr;
		constructedOptionName = nameArr;
		for(var i=0;i<constructedOptionName.length;i++){ldelim}
			//var nowName=userlabel+"::"+constructedOptionName[i];
            var nowName=constructedOptionName[i];
			var nowId=constructedOptionValue[i];
			//form.AllUsersAdmin.options[i]=new Option(nowName,nowId);
			form.AllUsers.options[i]=new Option(nowName,nowId);
		{rdelim}
	{rdelim}
	
{rdelim}
function dataProfileChange(obj)
{ldelim}
    if(obj.checked)
    {ldelim}
        obj.value=0;
    {rdelim}
    else
    {ldelim}
        obj.value=1;
    {rdelim}
{rdelim}
function getProfileChange(obj)
{ldelim}
    if(obj.checked)
    {ldelim}
        obj.value=0;
        document.getElementById("objtainaccountcontrolday").style.display='none';
    {rdelim}
    else
    {ldelim}
        obj.value=1;
         document.getElementById("objtainaccountcontrolday").style.display='';
    {rdelim}
{rdelim}

function publicStatusChange(obj)
{ldelim}
    var form=document.forms['EditView'];
   
     if (form.status.checked)
     {ldelim}
        form.dataProfile.disabled=false;
        form.getProfile.disabled=false;
        form.dataProfile.checked=true;
		form.user_name.disabled=false;
        form.normalconvertbuttonprofile.checked=true;//增加公海已分配客户转普通权限
		ld('#select_user_name').show();
		ld('#clear_user_name').show();
		form.allotuser_name.disabled=false;
		ld('#select_allotuser_name').show();
		ld('#clear_allotuser_name').show();
		ld('#publicaccount_div').css('display','');
		//ld('#s2id_m_newdropdownoption').show();
        ld("#radio_one_astricttype").prop("checked",true);
        
        //form.getProfile.checked=true;0013772: 控制面板--公海参数：公海设置，当勾选启用公海客户时，希望默认不勾选公海未分配客户不允许领取。
        form.wheathershow.checked=true;
        //form.dataProfile.value=0;
      //  form.getProfile.value=0;
       // form.wheathershow.value=0;
		ld(":radio").attr("disabled",false);
		ld(":checkbox").attr("disabled",false);
		ld("#completeopt_checkbox").attr("disabled","disabled");
        //34237: （7.4.0版本本地登录）公海参数设置界面：启用公海客户，自动回收规则设置中规则1 没有默认勾选
        ld(":checkbox[tag='chkdisabled']").attr("disabled",true);
        
		ld(":text").attr("disabled",false);
       
		form.status.disabled=false;
		ld('#useradmin_move_right').show();
		ld('#useradmin_move_left').show();
     {rdelim}
     else
     {ldelim}
        //form.dataProfile.checked=false;	
        //form.getProfile.checked=false;
        //form.wheathershow.checked=false;
       // form.dataProfile.disabled=true;
       // form.getProfile.disabled=true;
      //  form.wheathershow.disabled=true;
		form.user_name.disabled=true;
		ld('#select_user_name').hide();
		//ld('#clear_user_name').hide();
		form.allotuser_name.disabled=true;
	//	ld('#select_allotuser_name').hide();
	//	ld('#clear_allotuser_name').hide();
		ld('#publicaccount_div').css('display','none');
    //	ld('#s2id_m_newdropdownoption').hide();
     //   form.dataProfile.value=1;
     //   form.getProfile.value=1;
      //  form.wheathershow.value=1;
		ld(":radio").attr("disabled","disabled");
		ld(":checkbox").attr("disabled","disabled");
		//ld(":text").attr("disabled","disabled");
		form.status.disabled=false;
		ld('#useradmin_move_right').hide();
		ld('#useradmin_move_left').hide();
     {rdelim}
{rdelim}

function delColumn(type){ldelim}
	if(type){ldelim}
	var selectobj=getObj('selectedColumns');
	{rdelim}
	else{ldelim}
	var selectobj=getObj('selectedAdminColumns');
	{rdelim}
	for (i=selectobj.options.length;i>0;i--) 
	{ldelim}
		if (selectobj.options.selectedIndex>=0)
	selectobj.remove(selectobj.options.selectedIndex)
	{rdelim}
{rdelim}
//普通客户转为公海后，更改客户负责人为（为空表示不更改）
function select_accountuser()
{ldelim}
    var form=document.forms['EditView'];
    var allotuserid = form.userid.value;
	var scopepopupobj;//自定义弹出层页面html，绑定事件
	var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
	var module = 'Users';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){ldelim}
		var methodObj = {ldelim}'popup_check_inactiveuser':'yes'{rdelim};
		scopepopupobj =  new ScopePopupObj(methodObj);
		scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){ldelim}
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = allotuserid;
           cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&publiaccount=yes';
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){ldelim}
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){ldelim}
					if(empty(cls_ScopePopup.return_obj.return_id)){ldelim}
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
                    {rdelim}else{ldelim}
						var form=document.forms['EditView'];
						form.userid.value=cls_ScopePopup.return_obj.return_id;
						// form.user_name.value=cls_ScopePopup.return_obj.return_name;
            ld('#user_name').html(cls_ScopePopup.return_obj.return_name);
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					{rdelim}
                {rdelim});
            {rdelim}
		{rdelim});
	{rdelim});
{rdelim}
//公海已分配客户释放后，更改客户负责人为（为空表示不更改）
function select_allotuser()
{ldelim}
    var form=document.forms['EditView'];
    var allotuserid = form.allotuserid.value;
	var scopepopupobj;//自定义弹出层页面html，绑定事件
	var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
	var module = 'Users';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){ldelim}
		var methodObj = {ldelim}'popup_check_inactiveuser':'yes'{rdelim};
		scopepopupobj =  new ScopePopupObj(methodObj);
		scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){ldelim}
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = allotuserid;
           cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user';
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){ldelim}
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){ldelim}
					if(empty(cls_ScopePopup.return_obj.return_id)){ldelim}
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
                    {rdelim}else{ldelim}
						var form=document.forms['EditView'];
						form.allotuserid.value=cls_ScopePopup.return_obj.return_id;
						// form.allotuser_name.value=cls_ScopePopup.return_obj.return_name;
            ld('#allotuser_name').html(cls_ScopePopup.return_obj.return_name);
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					{rdelim}
                {rdelim});
            {rdelim}
		{rdelim});
	{rdelim});
{rdelim}
function clear_user()
{ldelim}
    var form=document.forms['EditView'];
    form.userid.value='';
    // form.user_name.value='';
    ld('#user_name').html('');
{rdelim}
function clear_publicaccount()
{ldelim}
    var form=document.forms['EditView'];
    form.allotuserid.value='';
    // form.allotuser_name.value='';
    ld('#allotuser_name').html('');
{rdelim}
    function isInteger(obj){ldelim} 
      
         return typeof obj === 'number' && obj%1 === 0;      //是整数，则返回true，否则返回false  
      
{rdelim}  
function choosepublicadmin()
{
     var select_id=document.forms['EditView'].selectedcolumnsforadmin.value;
	var scopepopupobj;//自定义弹出层页面html，绑定事件
	var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
	var module = 'Users';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){ldelim}
		var methodObj = {ldelim}'popup_check_inactiveuser':'yes'{rdelim};
		scopepopupobj =  new ScopePopupObj(methodObj);
		scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){ldelim}
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = select_id;
           cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&publiaccount=yes';
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){ldelim}
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){ldelim}
					if(empty(cls_ScopePopup.return_obj.return_id)){ldelim}
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
                    {rdelim}else{ldelim}
						var form=document.forms['EditView'];
						form.selectedcolumnsforadmin.value=cls_ScopePopup.return_obj.return_id;
						//form.user_name.value=cls_ScopePopup.return_obj.return_name;
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					{rdelim}
                {rdelim});
            {rdelim}
		{rdelim});
	{rdelim});


}
var adminaccount='{$ADMINACCOUNT}';//公海管理员
</script>