<script language="javascript" type="text/javascript" src="{$JSURL}include/js/special_webuploader.js"></script>

<script type="text/javascript">
    var current_language = "{$current_language}";
</script>
<script language="javascript" type="text/javascript"
        src="include/js/modules/Home/Coordination.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/search.js?v={$GLOBALMINVERSION}"></script>
<!-- <script language="javascript" type="text/javascript" src="modules/Home/swfobject.js"></script> -->
<script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
<input type="hidden" id="homecontrol" value="1">
{*<input type="hidden" id="deploy_value" value="{$DEPLOY}">*}
<input type="hidden" id="sendlog_workdate" value="{$sendlog_workdate}">
<input type="hidden" id="entitytype" value="{$entitytype}" >
<input type="hidden" id="type" value="{$type}">
<input type="hidden" id="approved" value="{$approved}">
<input type="hidden" id="textedit" value="{$EDIT_PERMIT.fields}">
<input type="hidden" id="workreportid" value="{$workreportid}">
<input type="hidden" name="download_permit" id="download_permit" value="{$download_permit}">
<input type="hidden" name="preview_permit" id="preview_permit" value="{$preview_permit}">
<input type="hidden" name="saleskit_showtype" id="saleskit_showtype" value="{$saleskit_showtype}">
<input type="hidden" name="saleskit_listinfo" id="saleskit_listinfo" value="{$saleskit_listinfo}">
<form name="sendLog" method="POST" action="index.php" ENCTYPE="multipart/form-data"
      onsubmit="puyoungJS_DialogBox.block();">
    <div class="ld-pop-container divPopOverflow">
        <div class="pubclear writeContent" id="sendLog">
            <div id="editTxt">
                <div tag="workfield">
                    <div type="worktype">
                        {foreach key=key item=item from=$WORKFIELDARRAY}
                        {if $key eq 'saleskit_day' || $key eq 'saleskit_week' || $key eq 'saleskit_month'}
                        <fieldset name="editfieldset" id="fieldset_{$key}" {if $item.defaultvalue eq ''} style = 'display:none'{/if}>
                            {else}
                            <fieldset name="editfieldset" {if $item.defaultvalue eq '' &&  $EDIT_PERMIT.fields eq 'noedit'} style = 'display:none'{/if}>
                                {/if}
                                <label style="font-weight: normal;">{if $item.is_mandatory eq '0'}
                                        <font color="red">*</font>
                                    {/if}{$item.label}</label>
                                <textarea class="sendLog" area="edittextarea" name='{$key}'
                                          is_mandatory='{$item.is_mandatory}'
                                          defaultvalue='{$item.defaultvalue}' {if $EDIT_PERMIT.fields eq 'noedit'}readonly ='true' style = 'color:#999'{else}style='height:{$item.defaultheight}px'  {/if}>{$item.defaultvalue}</textarea>
                                <a name="workreporteditcopy" class="workreporteditcopy marT-20" href="javascript:void(0);">{'COPY'|@getFixedLabel}</a>
                            </fieldset>
                            {/foreach}
                    </div>
                    {if $entitytype eq 'workreport' && $EDIT_PERMIT.fields neq 'noedit'}
                        <div entitytype='saleskit'>
                    {else}
                        <div entitytype='saleskit' class='ui-hide'>
                            {/if}
                            <fieldset>
                                <label tag={$type} class="ld-tab-work-data ld-tab-work-datashow">
                                    {'DATE'|@getFixedLabel}：
                                    {if $type eq 2 && $editDate eq 'yes'}
                                        <a href="javascript:void(0)" id="saleskit_week" class="curr_data">{$sendlog_workdate}</a>
                                        <a href="javascript:void(0)" id="saleskit_this_week" title="{'thisweek'|@getFixedLabel}">{'thisweek'|@getFixedLabel}</a>
                                        <a href="javascript:void(0)" id="saleskit_last_week" title="{'lastweek'|@getFixedLabel}">{'lastweek'|@getFixedLabel}</a>
                                        <a href="javascript:void(0)" id="saleskit_lastlast_week" title="{'beflastweek'|@getFixedLabel}">{'beflastweek'|@getFixedLabel}</a>
                                    {elseif $type eq 3 && $editDate eq 'yes'}
                                        <a href="javascript:void(0)" id="saleskit_month" class="curr_data">{$sendlog_workdate}</a>
                                        <a href="javascript:void(0)" id="saleskit_this_month" title="{'thismonth'|@getFixedLabel}">{'thismonth'|@getFixedLabel}</a>
                                        <a href="javascript:void(0)" id="saleskit_last_month" title="{'lastmonth'|@getFixedLabel}">{'lastmonth'|@getFixedLabel}</a>
                                        <a href="javascript:void(0)" id="saleskit_lastlast_month" title="{'beflastmonth'|@getFixedLabel}">{'beflastmonth'|@getFixedLabel}</a>
                                    {/if}

                                    <span id="kuohao_left">(</span>
                                    {if $type eq 1}
                                        {if $minDate neq 'all' && $maxDate neq 'all'}
                                            <a type="text" style="width:110px;height:25px;line-height:25px;" size="15" name="sendlog_saleskit_date" id="sendlog_saleskit_date" tmpvalue="{$sendlog_workdate}"
                                                onclick="WdatePicker({ldelim}opposite:true,disabledDates:[{$disabledDates}],onpicked:function(){ldelim}var this_value = ld('#sendlog_saleskit_date').html();getSendLog_SalesKit(this_value);{rdelim}{rdelim})">{$sendlog_workdate}</a>
                                        {else}
                                            <a type="text" style="width:110px;height:25px;line-height:25px;" size="15" name="sendlog_saleskit_date" id="sendlog_saleskit_date"
                                                onclick="WdatePicker({ldelim}onpicked:function(){ldelim}var this_value = ld('#sendlog_saleskit_date').html();getSendLog_SalesKit(this_value);{rdelim}{rdelim})">{$sendlog_workdate}</a>
                                        {/if}
                                    {else}
                                        <span tag="saleskit_date" id="span_saleskit_date">{$sendlog_workdate}</span>
                                    {/if}
                                    <span id="kuohao_right">)</span>

                                </label>
                            </fieldset>
                            <fieldset>
                                <label style="font-weight: normal;line-height: 24px">{'Jobbriefing'|@getFixedLabel}</label>
                                {if $type eq 1}
                                <a href="javascript:void(0)" title="{'Generatebrief'|@getFixedLabel}"
                                   id="saleskit_select_day"
                                   tag="">{'Generatebrief'|@getFixedLabel}</a>
                                {elseif $type eq 2}
                                <a href="javascript:void(0)" title="{'Generatebrief'|@getFixedLabel}"
                                   id="saleskit_select_week"
                                   tag="">{'Generatebrief'|@getFixedLabel}</a>
                                {elseif $type eq 3}
                                <a href="javascript:void(0)" title="{'Generatebrief'|@getFixedLabel}"
                                   id="saleskit_select_month"
                                   tag="">{'Generatebrief'|@getFixedLabel}</a>
                                {/if}
                                <div name="Salesbriefing">
                                    {include file="Home/Briefcomponent.tpl"}
                                </div>
                            </fieldset>
                        </div>
                    <fieldset id="sendLogAcctlist" {if $ACCOUNTSARR eq NULL}style="display:none"{/if} >
                        <div>
                            <label>{'Accounts'|@getTransTab}</label>
                            <ul class="reader-bar-list">
                                {foreach key=key item=item name=nav from=$ACCOUNTSARR}
                                    <li accountid={$item.curid}>
                                        <span class="item-name">{$item.name}</span>
                                        <span class="remove-h" {if $EDIT_PERMIT.related eq 'noedit'}style="display:none"{/if} >×</span>
                                    </li>
                                {/foreach}
                            </ul>
                        </div>
                    </fieldset>
                    <fieldset id="sendLogContlist" {if $CONTACTSARR eq NULL}style="display:none"{/if} >
                        <div>
                            <label>{'Contacts'|@getTransTab}</label>
                            <ul class="reader-bar-list">
                                {foreach key=key item=item name=nav from=$CONTACTSARR}
                                    <li contactid={$item.curid}>
                                        <span class="item-name">{$item.name}</span>
                                        <span class="remove-h" {if $EDIT_PERMIT.related eq 'noedit'}style="display:none"{/if} >×</span>
                                    </li>
                                {/foreach}
                            </ul>
                        </div>
                    </fieldset>
                    <fieldset id="sendLogProlist" {if $PRODUCTSARR eq NULL}style="display:none"{/if}>
                        <div>
                            <label>{'Products'|@getTransTab}</label>
                            <ul class="reader-bar-list">
                                {foreach key=key item=item name=nav from=$PRODUCTSARR}
                                    <li productid={$item.curid}>
                                        <span class="item-name">{$item.name}</span>
                                        <span class="remove-h" {if $EDIT_PERMIT.related eq 'noedit'}style="display:none"{/if} >×</span>
                                    </li>
                                {/foreach}
                            </ul>
                        </div>
                    </fieldset>
                    <fieldset id="sendLogUploadImg" {if $IMAGESARR eq NULL}style="display:none"{/if}>
                        <div>
                            <label>{'PICTURE'|@getFixedLabel}</label>
                            <ul class="upload-img pubclear uploader-list">
                                {foreach key=key item=item name=nav from=$IMAGESARR}
                                    <li record="{$item.id}" style="display: flex;align-items: center;width: 100%">
                                        <span class="item-name">
                                            <img class="name-img" alt="" src="{$item.src}">
                                        </span>
                                        <span class="webuploadDelbtn overflow-space" style="max-width: 50%;padding-left: 5px">{$item.name}<span class="state" style="padding-left:5px"><span style="color:#798699;">({$item.size})</span></span></span>
                                        {if $EDIT_PERMIT.workachment eq 'edit'}
                                            <span class="webuploadDelbtn" style="padding-left:10px"><a href="javascript:void(0)"  data-record="{$item.id}" tag="img_delete" name="delete_'+{$item.id}+'" data-id="'+{$item.id}+'">{'DELETE'|@getFixedLabel}</a></span>
                                        {/if}
                                        {if $download_permit eq 'yes'}
                                            <span class="padL10">
                                                <a target="_blank" href="index.php?module=Home&action=HomeAjax&file=openattachment&fildid={$item.id}" style="margin-right: 5px;"><span>{'DOWNLOAD'|@getFixedLabel}</span></a>
                                            </span>
                                        {/if}
                                        {if $preview_permit eq 'yes'}
                                        <span class="webuploadPrebtn" style="padding-left:10px">
                                            <img style="display: none" src="{$item.src}">
                                            <a href="javascript:void(0);" onclick="previewImage(ld(this).parents('.uploader-list').get(0));ld(this).parent().find('img').click();"><span>{'PREVIEW'|@getFixedLabel}</span></a>
                                        </span>
                                        {/if}
                                    </li>
                                {/foreach}
                            </ul>
                        </div>
                    </fieldset>
                    <fieldset id="sendLogUploadAtt" {if $ATTARR eq NULL}style="display:none"{/if}>
                        <div>
                            <label>{'Attachment'|@getFixedLabel}</label>
                            <ul class="upload-att pubclear uploader-list">
                                {foreach key=key item=item name=nav from=$ATTARR}
                                    <li record="{$item.id}" style="display: flex;align-items: center;width: 100%">
                                        <img alt="{$item.name}" src="themes/softed/images/file.png">
                                        <span class="webuploadDelbtn overflow-space" style="max-width: 50%; ">{$item.name}<span class="state" style="padding-left:5px"><span style="color:#798699;">({$item.size})</span></span></span>
                                        {if $EDIT_PERMIT.workachment eq 'edit'}
                                            <span class="webuploadDelbtn" style="padding-left:10px"><a href="javascript:void(0)" data-record="{$item.id}" tag="att_delete" name="delete_'+{$item.id}+'" data-id="'+{$item.id}+'">{'DELETE'|@getFixedLabel}</a></span>
                                        {/if}
                                        {if $download_permit eq 'yes'}
                                            <span class="padL10">
                                                <a target="_blank" href="index.php?module=Home&action=HomeAjax&file=openattachment&fildid={$item.id}" style="margin-right: 5px;"><span>{'DOWNLOAD'|@getFixedLabel}</span></a>
                                            </span>
                                        {/if}
                                        {if $preview_permit eq 'yes'}
                                            <span class="webuploadPrebtn" style="padding-left:10px">
                                                <a href="javascript:void(0);" onclick="open_Attachment({$workreportid},{$item.id},'CooperativeWork','{$item.name}')"><span>{'PREVIEW'|@getFixedLabel}</span></a>
                                            </span>
                                        {/if}
                                    </li>
                                {/foreach}
                            </ul>
                        </div>
                    </fieldset>
                </div>
            <div id="queue"></div>
            <div class="btns" style="position:relative">
                <a class="addemojicookie addemojicookie_reply" style='display:none' tag="addemojicookie_reply" href="javascript:void(0);" title="添加表情"></a>
                {if $EDIT_PERMIT.workachment neq 'noedit'}
                <a class="addimg" href="javascript:void(0);" title="{'ADDPICTURES'|@getFixedLabel}">
                    <div name="multiple" id="multiple" class="homeAddfu"></div>
                </a>
                <a class="addfu" href="javascript:void(0);" title="{'ADDATTACHMENTS'|@getFixedLabel}">
                    <div name="multiple_att" id="multiple_att" class="wu-example homeAddfu"></div>
                </a>
                {/if}
                {if $EDIT_PERMIT.toUsers neq 'noedit'}
                <a class="addtouch" href="javascript:void(0);" title="{'ADDCOLLEAGUES'|@getFixedLabel}"></a>
                {/if}
                {if $EDIT_PERMIT.related neq 'noedit'}
                <a class="addcustomer" href="javascript:void(0);" title="{'Accounts'|@getTransTab}"></a>
                <a class="addcontact"  href="javascript:void(0);" title="{'Contacts'|@getTransTab}"></a>
                <a class="addproducts" href="javascript:void(0);" title="{'Products'|@getTransTab}"></a>
                {/if}
            </div>
            <div class="pubclear pubEnd" id='sendLogFoot'>
                {if {$entitytype} eq 'cocmd'}
                <div class="panel cocmd" tag='cmduser'>
                    <div style="vertical-align: middle; line-height: 30px;">
                        <span class="pep-label">{'Completiontime'|@getFixedLabel}</span>
                        <input type="text" id="d241" onclick="WdatePicker({ldelim}dateFmt:'yyyy年MM月dd日'{rdelim})"
                               class="Wdate-noimg" placeholder="{'pleaseselectdate'|@getFixedLabel}" value = {$startdate1}>
                        <input type="text" id="d242" onclick="WdatePicker({ldelim}dateFmt:'HH:mm'{rdelim})"
                               class="Wdate-noimg" placeholder="{'pleaseselectdate'|@getFixedLabel}" value = {$startdate2}>
                    </div>
                </div>
                {/if}
            </div>
        </div>
    </div>
    </div>
</form>
