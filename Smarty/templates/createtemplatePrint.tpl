<body style="margin:0 auto;width:100%;" class=small>
<link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/TemplatePrint.css" />
<script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/webuploader.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/special_webuploader.js"></script>
<link rel="stylesheet" type="text/css" href="uploaddify/uploadify.css">
<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />
<style type="text/css">
{literal}
.upload-file-name{
	background: none repeat scroll 0 0 #1ea0da;
    border: 1px solid #057bac;
    border-radius: 2px;
    box-shadow: 0 1px 0 #61c8ee inset;
    color: #fff;
    display: list-item;
    float: left;
    min-height: 20px;
    line-height: 20px;
    margin: 5px 3px 0 0;
    padding: 0 0.5em;
}
.upload-file-name .item-name {
    height: 8px;
    width: 12px;
	word-wrap:break-word;white-space:normal;word-break:break-all;
}
.upload-file-name .remove-h {
    color: #a4d9ef;
    cursor: pointer;
    font-size: 16px;
    font-weight: 700;
    padding-left: 6px;
}
{/literal}
</style>
<div class="divPopOverflow padT20">
<form action="index.php" method="post" name="TemplatePrintform" class="ajax_form">
    <input type="hidden" name="printtabid" value="{$PRINTTABID}"/>
    <input type="hidden" name="mode" value="{$MODE}"/>
    {if $MODE neq 'create'}
        <input type="hidden" name="printid" value="{$PRINTID}"/>
    {/if}
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <div class="ld-pop-container padT0 padB0">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'BASICINFO'|@getFixedLabel}</div>
        </div>
    </div>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font> {'TEMPLATENAME'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                {if $TEMPLATECOPY neq 1}
                    <input class="ld-input-inner" type="text" name="templatename" value="{$TEMPLATENAME}" />
                {else}
                    <input class="ld-input-inner" type="text" name="templatename" />
                {/if}
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                {'WHETHERDEFAULT'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                {if $ISDEFAULT eq 0}
                    <input type="checkbox" value="0" class="second_switch" name="isDefault" onclick="setTemplateDefault(this)">
                {else}
                    <input type="checkbox" value="1" class="second_switch" name="isDefault" checked="true" onclick="setTemplateDefault(this)">
                {/if}
            </td>
        </tr>
        <tr>
            {*ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印*}
            <td class="ld-form-item-label">
                {'ApprovedAllowPrint'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input name="approvedallowprint" {if $ApprovedAllowPrint eq 'yes'}checked{/if} class="second_switch" type="checkbox" >
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                {'REPLACEVARIABLEEMPTY'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <select name="replacespacevalue" class="ld-input-inner">
                    <option></option>
                    {if $REPLACESPACEVALUE eq '--'}
                        <option value="--" selected="true">--</option>
                    {else}
                        <option value="--">--</option>
                    {/if}
                    {if $REPLACESPACEVALUE eq '/'}
                        <option value="/" selected="true">/</option>
                    {else}
                        <option value="/">/</option>
                    {/if}
                     {if $REPLACESPACEVALUE eq "\\"}
                        <option value="\" selected="true">\</option>
                     {else}
                        <option value="\">\</option>
                     {/if}
                </select>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                {'VARIABLEINFORMATION'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <div class="lfloat ModuleFielddiv">
                    <select name="TemplateprintList_moduleSel" fieldtype="selecttype" onchange="TemplateprintList.moduleSel(this)" class="ld-select-inner">
                        <option value="0">{'PLEASESELECTRELEVANTMODULE'|@getFixedLabel}</option>
                        {foreach item=tablabel key=tabid from=$PRINTTABS}
                            {if $tabid eq $PRINTTABID}
                                <option value="{$tabid}" selected="true">{$tablabel}</option>
                            {else}
                                <option value="{$tabid}">{$tablabel}</option>
                            {/if}
                        {/foreach}
                    </select>
                </div>
                <div name="tabField" id="tabField" class="lfloat padL10 ModuleFielddiv">
                    <select name="TemplateprintList_fieldSel" fieldtype="selecttype" class="ld-select-inner" onchange="TemplateprintList.fieldSel(this)"><option>{'PLEASESELECTFIELD'|@getFixedLabel}</option></select>
                </div>
                <div class="lfloat padLR10"><input type="text" name="selField" id="selField" class="ld-input-inner" style="width:200px;" /></div>
                {if $TYPE eq 'Word' || $TYPE eq 'Excel'}
                    <b id="copy_icon" href="javascript:;" style="margin:7px 0;cursor:pointer;" data-tip="{'COPY'|@getFixedLabel}" data-direction="top" data-type="position" class="restore-default-icon restore-default-icon-copy tip-items-list" onclick="TemplateprintList.CopyPlaceholder(this)" ></b>
                    <a class="Anu3_a" filepath="{$DefaultTemplate}" onclick="TemplateprintList.DownloadDefaultTemplate(this)" style="line-height: 26px;">{'DOWNLOAD'|@getFixedLabel}{$TYPE}{'PresetTemplate'|@getFixedLabel}</a>
                {else}
                    <input type="button" name="insertHtml" class="ld-button ld-button-primary" value="{'INSERTINTOPRINTTEMPLATE'|@getFixedLabel}" onclick="TemplateprintList.InsertTemplate(this)"/>
                {/if}
            </td>
        </tr>
        {if $TYPE eq 'Word' || $TYPE eq 'Excel'}
            <tr>
                <td class="ld-form-item-label">
                    <font color="red">*</font> {'UploadTemplate'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <div class="fileinput-box">
                        <input type="hidden" name="I_file_filename" id="I_file_filename" value="" />
                        <div name="UploadFile" class="wu-example" style="display: flex;">
                        </div>
                    </div>
                </td>
            </tr>
            {if $Errortips neq ''}
                <tr>
                    <td class="ld-form-item-label">
                    </td>
                    <td class="ld-form-item-content">
                        <div style="padding: 5px 0px;color:red;">{$Errortips}</div>
                    </td>
                </tr>
            {/if}
            <tr>
                <td class="ld-form-item-label">
                </td>
                <td class="ld-form-item-content">
                    <div style="padding: 5px 0px;">1. {if $TYPE eq 'Excel'}{'ExcelTemplateSupportFile'|@getFixedLabel}xlsx{else}{'WordTemplateSupportFile'|@getFixedLabel}docx{/if}</div>
                    <div style="padding: 5px 0px;">2. {if $TYPE eq 'Excel'}{'CopyInformationToExcelTemplateAndUpload'|@getFixedLabel}{else}{'CopyInformationToTemplateAndUpload'|@getFixedLabel}{/if}</div>
                </td>
            </tr>
        {else}
            <tr>
                <td class="ld-form-item-label">
                    {'INSERTINTOPRINTTEMPLATE'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <textarea id="CKTemplatePrint" name="CKTemplatePrint" type="text/plain" style="width:660px;height:100px;">{$CKEDITORHTML}</textarea>
                </td>
            </tr>
        {/if}
    </table>
    <div class="ld-pop-container padT28 padB0">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'SELECT'|@getFixedLabel}</div>
        </div>
    </div>
    <div id="divPrint" class="ld-pop-container padT8 padB0 lineheight24">
        [<a tag="print_1">{'GENERALINFO'|@getFixedLabel}</a>]<i></i>
        [<a tag="print_2">{'COMPANYINFOMATION'|@getFixedLabel}</a>]<i></i>
        [<a tag="print_3">{'PERSONCHARGEINFOMATION'|@getFixedLabel}</a>]<i></i>
        {if $haveProductDetails=='yes'}
            [<a tag="print_4">{'Products'|@getTranstab} {'DETAIL'|@getFixedLabel}</a>]<i></i>
            [<a tag="print_6">{$mokuai_name} {'Products'|@getTranstab} {'DETAIL'|@getFixedLabel}</a>]<i></i>
        {/if}
        [<a tag="print_7">{'APPROVALHISTORY'|@getFixedLabel}</a>]<i></i>
        [<a tag="print_8">{'RECEIVEINFO'|@getFixedLabel}</a>]<i></i>
        [<a tag="print_9">{'PLANNEDDATEPAYMENTINFO'|@getFixedLabel}</a>]<i></i>
        {if $BLOCKFIELDLABEL neq ''}
            [<a tag="print_10">{'Accounts'|@getTranstab} - {$BLOCKFIELDLABEL}</a>]<i></i>
        {/if}
        [<a tag="print_11">{'MOREINFORMATION'|@getFixedLabel}</a>]<i></i>
        [<a tag="print_12">{'Productinformationintabularformat'|@getFixedLabel}</a>]
    </div>
    {include file='PrintHtml.tpl'}
</form>
</div>
<input type="hidden" id="current_userid" value='{$CURRENT_USERID}'/>
</body>
<!-- 导入excel文件到打印模板中 end -->
<script type="text/javascript">
var onlyuploadxlshtml = '{"LBL_ONLYUPLOADXLSHTML"|@getFixedLabel}';
var myatt_id = document.getElementById("current_userid").value;
{literal}
ld(function () {
	//渲染容器
	ld("[name=multiple_att").special_powerWebUpload({ 
		fileTypeDuplicate:'yes',	//附件类型判断
		fileNameDuplicate:'yes',	//同名附件判断
		mode:'',	//当前单据 create or edit
		module:'',	//当前模块
		jsonData:'',	//edit data,编辑界面显示已上传的附件
		record:'',	//单据单据id
        uitype:'',
		supportformat:'',//支持格式
		inputFileName:'',	//选择附件后赋值标签的name
		attach_server:'index.php?module=Settings&action=SettingsAjax&file=UploadExcel&creaetetemplate=yes&uploadtype=uploadexcel&myatt_moduel=Settings&myatt_id='+myatt_id
	});
})

//判断非空
function empty(v){
	switch (typeof v){
		case 'undefined' : return true;
		case 'string' : if(trim(v).length == 0) return true; break; 
		case 'boolean' : if(!v) return true; break; 
		case 'number' : if(0 === v) return true; break; 
		case 'object' : 
		if(null === v) return true; 
		if(undefined !== v.length && v.length==0) return true; 
		for(var k in v){return false;} return true; 
		break; 
	}
	return false; 
}
{/literal}
</script>