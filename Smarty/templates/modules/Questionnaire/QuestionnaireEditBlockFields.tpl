{*@edit:liushuai,2021-04-28,reason:【ID1001572】增加【调查问卷】模块-第一版*}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/colpick/colpick.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/colpick/plugin.js"></script>
<script language="JAVASCRIPT" type="text/javascript"
        src="{$JSURL}include/js/modules/Questionnaire/Questionnaire.js"></script>
<link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/Questionnaire.css"/>

{*复制链接用到的js*}
<script language="javascript" type="text/javascript"
        src="include/js/clipboard.min.js?v={$GLOBALMINVERSION}"></script>

<div>
    <input type="hidden" name="step" value="{$step}">
    <div class="multi-step">
        <div class="step {if $step eq 1}current {/if}">
            <label>{'Customizedquestionnaire'|@getFixedLabel}</label>
            <div class="socialdot"></div>
        </div>
        <div class="step {if $step eq 2}current {/if}">
            <label>问题设置</label>
            <div class="socialdot"></div>
        </div>
        <div class="step {if $step eq 3}current {/if}">
            <label>{'Conclusionsetting'|@getFixedLabel}</label>
            <div class="socialdot"></div>
        </div>

        <div class="step {if $step eq 4}current {/if}">
            <label>{'SPCOMPLETED'|@getFixedLabel}</label>
            <div class="socialdot"></div>
        </div>
    </div>

    <div class="stepContent " id="step1" style="display: block;">
        <table style="float: left;table-layout: fixed;" id="coustomPage" class="ld-createedit-tablecontent Questionnaire linefeed  social-form"
               width="60%" cellspacing="0" cellpadding="0" border="0">
            <tbody>
            <tr>
                <td style="width: 200px"></td>
                <td style="width: calc(100% - 200px)"></td>
                <td style="width: 200px"></td>
                <td style="width: calc(100% - 200px)"></td>
            </tr>
            {foreach key=key item=data from=$BLOCKS name=blocknames}{*$smarty.foreach.block.index+1*}
                {foreach key=mainlabel item=maindata from=$data}
                    {assign var="uitype" value=$maindata[0][0][0]}
                    {assign var="fieldonly" value=$maindata[0][1][0]}
                    {assign var="fldlabel" value=$maindata[1][0]}
                    {assign var="fldlabel_sel" value=$maindata[1][1]}
                    {assign var="fldlabel_combo" value=$maindata[1][2]}
                    {assign var="fldlabel_other" value=$maindata[1][3]}
                    {assign var="fldname" value=$maindata[2][0]}
                    {assign var="fldvalue" value=$maindata[3][0]}
                    {assign var="secondvalue" value=$maindata[3][1]}
                    {assign var="thirdvalue" value=$maindata[3][2]}
                    {assign var="typeofdata" value=$maindata[4]}
                    {assign var="colname" value=$maindata[5]}
                    {assign var="vt_tab" value=$maindata[5][0]}
                    {if $uitype eq 15}

                        {assign var="optText" value=$maindata[6]}

                    {/if}
                    {assign var="allowedit" value=$maindata['allowedit']}
                    {assign var="allowedit_presence" value=$maindata['allowedit_presence']}
                    {assign var="allowcreate" value=$maindata['allowcreate']}
                    {assign var="allowcreate_presence" value=$maindata['allowcreate_presence']}
                    {assign var="allowprofileeditfield" value=$maindata['profileeditfield']}
                    {assign var='value_name' value=$maindata['value_name']}
                    {if $typeofdata eq 'M'}
                        {assign var="mandatory_field" value="*"}
                    {else}
                        {assign var="mandatory_field" value=""}
                    {/if}
                    {* vtlib customization: Help information for the fields *}
                    {assign var="usefldlabel" value=$fldlabel}
                    {assign var="fldhelplink" value=""}
                    {* $uitype值为 2 26 53 4 19 28 56 27 1 *}
                    {if $FIELDHELPINFO && $FIELDHELPINFO.$fldname}
                        {assign var="fldhelplinkimg" value='help_icon.gif'|@lingdang_imageurl:$THEME}
                        <!--assign var="fldhelplink" value="<img style='cursor:pointer' onclick='vtlib_field_help_show(this, \"$fldname\");' border=0 src='$fldhelplinkimg'>"-->
                        {if $uitype neq '10'}
                            {assign var="usefldlabel" value="$fldlabel $fldhelplink"}
                        {/if}
                    {/if}

                    {if $maindata[5] == 'name'}
                        <tr>
                            <td class="ld-form-item-label">
                                <div class="social-form-div">
{*                                    <label><font color="red">*</font>{$usefldlabel}</label>*}
                                    <label><font color="red">*</font>{$fldlabel}</label>
                                </div>
                            </td>
                            <td class="ld-form-item-content">
                                <div class="social-form-div">
                                    <input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}"
                                           id="{$fldname}" value="{$fldvalue}"
                                           class="ld-input-inner">
                                </div>
                            </td>
                        {elseif $maindata[5] == 'accountid'}
                            <td class="ld-form-item-label">
                                <div class="social-form-div">
                                    <label>{$fldlabel}</label>
                                </div>
                            </td>
                            <td class="ld-form-item-content">
                                <input name="{$fldname}_name" id="single_accountid" type="text" fieldonly='{$fieldonly}' fieldname="{$fldname}" value="{$fldvalue}"{if $fldvalue neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'Accounts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Accounts',event],event)" autocomplete="off" >
                                <input name="{$fldname}" type="hidden" value="{$secondvalue}" >
                                {if $fromlink neq 'batchcreate'}
                                    <a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist_special("{$MODULE}","Accounts","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
                                    <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','{$fldname}','{$fldname}_name','realaccountid','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
                                {/if}
                                <div class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
                            </td>
                        </tr>
                        {elseif $maindata[5] == 'category'}
                        <tr>
                            <td class="ld-form-item-label">
                                <div class="social-form-div">
                                    <label>{$fldlabel}</label>
                                </div>
                            </td>
                            <td class="ld-form-item-content">
                                <div class="social-form-div">
                                    <select name="{$fldname}" tabindex="{$vt_tab}"  id="{$fldname}" fieldonly='{$fieldonly}' class="ld-select-inner">
                                        <option value="外部" {if $fldvalue eq '外部'}selected{/if}>{'EXTERNAL'|@getFixedLabel}</option>
                                        <option value="内部" {if $fldvalue eq '内部'}selected{/if}>{'INTERNAL'|@getFixedLabel}</option>
                                    </select>
                                </div>
                            </td>
                    {elseif $maindata[5] == 'description'}
                        <td class="ld-form-item-label">
                            <div class="social-form-div">
                                <label>{$fldlabel}</label>
                            </div>
                        </td>
                        <td class="ld-form-item-content">
                            <div class="social-form-div">
                                <textarea tabindex="{$vt_tab}" name="{$fldname}" id="{$fldname}" value="{$fldvalue}"
                                        placeholder="{'QuestionnaireDescribingPlaceholder'|@getFixedLabel}"
                                        class="ld-textarea-inner"
                                        style="height: 100px;">{$fldvalue}</textarea>
                            </div>
                            <style>#description{ max-height: 300px!important;min-height: 100px!important;overflow: auto!important; }</style>
                        </td>
                    </tr>
                    {elseif $maindata[5] eq 'recovery_endtime'}
                    <tr>
                        <td class="ld-form-item-label">
                            <div>{$fldlabel}</div>
                        </td>
                        <td class="Q_setTime ld-form-item-content">
                            <div class="social-form-div select-input">
                                <input class="Q_setTimeCheck" type="checkbox" name="recovery_settings" {if $value_name neq ''}checked{/if}/>{'SetEndTime'|@getFixedLabel}
                                <input type="text" name="{$fldname}" id="{$fldname}" value="{$value_name}" tabindex="{$vt_tab}"
                                    class="Wdate Q_setTimeWdate ld-input-inner" autocomplete="off" style="{if $value_name eq ''}display: none;{/if}border:1px solid #dbdbdb;width: 200px;"
                                    fieldlabel="{$fldlabel}" fieldonly="{$fieldonly}" size="25" maxlength="10" value=""
                                    onclick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim});"/>
                            </div>
                        </td>
                    </tr>
                    {elseif $maindata[5] neq 'recovery_endremarks'}{*和结束语设置重名，富文本编辑框出错*}
                        {if $uitype eq 53}
                            {if $ID > 0}
                                <tr style="display: none;">
                                    <td width="20%" class="DetailedTd1Label" align="right">
                                        {$usefldlabel}
                                    </td>
                                    <td width="30%" align="left" class="DetailedTd2Info">
                                        {foreach key=key_one item=arr from=$fldvalue}
                                            {foreach key=sel_value item=value from=$arr}
                                                {if $value eq 'selected'}
                                                    <input type="hidden" id="{$fldname}" name="{$fldname}" value="{$key_one}">{$sel_value}
                                                {/if}
                                            {/foreach}
                                        {/foreach}
                                    </td>
                                </tr>
                            {else}
{*                                {include file='DetailView/Smowner.tpl'}*} {* 编辑或新建界面  默认负责人不显示*}
                            {/if}
                        {else}
                            <tr style="display: none;">
                                <input type="hidden" id="{$fldname}" name="{$fldname}" value="{$fldvalue}">
                            </tr>
                        {/if}

                    {/if}

                {/foreach}
            {/foreach}

            </tbody>
        </table>
    </div>

    <div class="stepContent " id="step2" style="display: block;">
        <table style="float: left;" id="coustomPage" class="ld-createedit-tablecontent Questionnaire linefeed  social-form"
               width="60%" cellspacing="0" cellpadding="0" border="0">
            <tbody>
            {foreach key=key item=data from=$BLOCKS name=blocknames}{*$smarty.foreach.block.index+1*}
                {foreach key=mainlabel item=maindata from=$data}
                    {assign var="uitype" value=$maindata[0][0][0]}
                    {assign var="fieldonly" value=$maindata[0][1][0]}
                    {assign var="fldlabel" value=$maindata[1][0]}
                    {assign var="fldlabel_sel" value=$maindata[1][1]}
                    {assign var="fldlabel_combo" value=$maindata[1][2]}
                    {assign var="fldlabel_other" value=$maindata[1][3]}
                    {assign var="fldname" value=$maindata[2][0]}
                    {assign var="fldvalue" value=$maindata[3][0]}
                    {assign var="secondvalue" value=$maindata[3][1]}
                    {assign var="thirdvalue" value=$maindata[3][2]}
                    {assign var="typeofdata" value=$maindata[4]}
                    {assign var="colname" value=$maindata[5]}
                    {assign var="vt_tab" value=$maindata[5][0]}
                    {if $uitype eq 15}

                        {assign var="optText" value=$maindata[6]}

                    {/if}
                    {assign var="allowedit" value=$maindata['allowedit']}
                    {assign var="allowedit_presence" value=$maindata['allowedit_presence']}
                    {assign var="allowcreate" value=$maindata['allowcreate']}
                    {assign var="allowcreate_presence" value=$maindata['allowcreate_presence']}
                    {assign var="allowprofileeditfield" value=$maindata['profileeditfield']}
                    {assign var='value_name' value=$maindata['value_name']}
                    {if $typeofdata eq 'M'}
                        {assign var="mandatory_field" value="*"}
                    {else}
                        {assign var="mandatory_field" value=""}
                    {/if}
                    {* vtlib customization: Help information for the fields *}
                    {assign var="usefldlabel" value=$fldlabel}
                    {assign var="fldhelplink" value=""}
                    <!--$uitype值为 2 26 53 4 19 28 56 27 1 -->
                    {if $FIELDHELPINFO && $FIELDHELPINFO.$fldname}
                        {assign var="fldhelplinkimg" value='help_icon.gif'|@lingdang_imageurl:$THEME}
                        <!--assign var="fldhelplink" value="<img style='cursor:pointer' onclick='vtlib_field_help_show(this, \"$fldname\");' border=0 src='$fldhelplinkimg'>"-->
                        {if $uitype neq '10'}
                            {assign var="usefldlabel" value="$fldlabel $fldhelplink"}
                        {/if}
                    {/if}
                    {if $maindata[5] eq 'recovery_endtime'}
                        <tr>
                            <td colspan="4">
                                {*                                <div class="selectField">*}
                                {*                                    <span>{'TopicSetting'|@getFixedLabel}</span>*}
                                {*                                    <button class="btn-add" name="addquestion" type="button"*}
                                {*                                            tagclick="Questionnaire.addQuestionTopic">{'AddTopic'|@getFixedLabel}*}
                                {*                                    </button>*}
                                {*                                </div>*}
                                {*                                <div>*}
                                {*                                    <table cellspacing="1" cellpadding="0" style="width: 760px;" name="topic_table" onchange="Questionnaire.prototype.bindTableChange(ld(this));">*}
                                {*                                    <table cellspacing="1" cellpadding="0" style="" name="topic_table" width="100%">*}
                                {*                                        <input type="hidden" name="topic_row_cnt" value="{$topic_row_cnt}">*}
                                {*                                        <tbody>*}
                                {*                                        <tr rowindex=1>*}
                                {*                                            <th style="text-align:center">{'Topicname'|@getFixedLabel}</th>*}
                                {*                                            <th style="text-align:center">{'Topictype'|@getFixedLabel}</th>*}
                                {*                                            <th style="text-align:center">{'Required'|@getFixedLabel}</th>*}
                                {*                                            {if $ID lte 0}*}
                                {*                                            <th style="text-align:center">{'OPERATING'|@getFixedLabel}</th>*}
                                {*                                            {elseif $status =='暂停' || $DUPLICATE == 'true'}*}
                                {*                                                <th style="text-align:center">{'OPERATING'|@getFixedLabel}</th>*}
                                {*                                            {/if}*}
                                {*                                        </tr>*}

                                {*                                        <tr rowindex=2 {if $ID lte 0 && $DUPLICATE!='true'}{else}style="display: none;{/if}"> 小于等于 0*}
                                {*                                            <td colspan="4" style="text-align:center;">{'Noquestions'|@getFixedLabel}</td>*}
                                {*                                        </tr>*}

                                {*                                        </tbody>*}
                                {*                                    </table>*}
                                {*                                </div>*}
                                <div id="" style="width: 100%;justify-content: center;">
                                    <div name="LayoutBlockContent" id="LayoutBlockContent" style="margin-bottom: 20px;">
{*                                        {include file='modules/Questionnaire/QuestionnaireBlockContent.tpl'}*}
                                    </div>
                                </div>
                            </td>
                        </tr>


                    {/if}

                {/foreach}
            {/foreach}

            </tbody>
        </table>
    </div>

    <div class="stepContent" id="step3" style="display: none;">
        <table style="float: left;table-layout: fixed;width: 80%;margin-left: 10%;margin-right: 10%;" id="" 
        class="ld-createedit-tablecontent Questionnaire linefeed  social-form"
               width="60%" cellspacing="0" cellpadding="0" border="0">
            <tbody>
            <tr>
                <td style="width: 200px"></td>
                <td style="width: calc(100% - 200px)"></td>
                <td style="width: 200px"></td>
                <td style="width: calc(100% - 200px)"></td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    {'Conclusionsetting'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content" colspan="3" style="padding: 5px 10px;">{*UE.getEditor('recovery_endremarks') 不能重名，前面已经有一个隐藏的recovery_endremarks*}
                        <textarea id="recovery_endremarks" name="recovery_endremarks" type="text/plain"
                                  style="width:98%;height:100px;resize: unset!important;">{$CKEDITORHTML}</textarea>
                </td>
            </tr>
            </tbody>
        </table>

    </div>


    <div class="stepContent " id="step4" style="display: none;">
        <div class="step4Content">
            <div class="success-tip">
                <img src="themes/images/complete.png"/>
                <span>{'ACTIVITYCREATEDSUCCESSFULLY'|@getFixedLabel}</span>
            </div>
            <div name="startquestionnaire" style="width: 100%;text-align: center;margin: 10px 0;display: none;">
                <div name="set_questionnaire_status" class="ld-button ld-button-primary">立即回收</div>
            </div>
            <table name="sharequestionnairetable" cellspacing=1 cellpadding=0 style="width: 100%;border-collapse: collapse;display: none;">
                <thead>
                <tr>
                    <td colspan="2" class="step4tip">问卷分享</td>
                </tr>
                </thead>

                <tbody>
                <tr>
                    <td style="width: 30%;" name="lastname"></td>
                    <td>
                        <div class="qrcode">
                            <div class="qrcode_img">
                                <img src="" name="Qrcode"/>
                                <span>{'ACTIVITYMOBILEPHONESCANANDSHARE'|@getFixedLabel}</span>
                            </div>
                            <div class="qrcode_a qrcode_q">
                                <a href="" target="_blank" name="Qrcode_url">{'ACTIVITYDOWNEWM'|@getFixedLabel}</a>
                                <a href="javascript:void(0)" class="copyUrl" data-clipboard-text="" name="share_url">{'ACTIVITYCOPYURL'|@getFixedLabel}</a>
                                <a href="" target="_blank" name="questionnaire_url">{'OpenQuestionnaire'|@getFixedLabel}</a>
                            </div>
                        </div>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>