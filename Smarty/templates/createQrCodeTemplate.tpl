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
<body style="margin:0 auto;width:100%;" class=small>
<link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/TemplatePrint.css" />
<link rel="stylesheet" type="text/css" href="uploaddify/uploadify.css">
<link rel="stylesheet" type="text/css" href="themes/softed/Control.css" />
<script type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
<script type="text/javascript" src="include/js/special_webuploader.js"></script>

<form action="index.php" method="post" name="new"  class="ajax_form">
    <input type="hidden" name="replacespacevalue" value="--"/>
    <input type="hidden" name="mode" value="{$MODE}"/>
    <input type="hidden" id="fieldid" name="fieldid" value="{$fieldid}"/>
    <input type="hidden" id="qrcodetemplateid" name="qrcodetemplateid" value="{$qrcodetemplateid}"/>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td align="right">
                {'VARIABLEINFORMATION'|@getFixedLabel}
            </td>
            <td align="left">
                <select  id="qrcodeTemplateModuleSel" onchange="qrcodeTemplate.moduleSel(this)" class="lfloat ModuleField btn-radius-system">
                    <option value="0">{'PLEASESELECTRELEVANTMODULE'|@getFixedLabel}</option>
                    {foreach item=tablabel key=tabid from=$PRINTTABS}
                        <option {if $selectedModuleId==$tabid} selected {/if}value="{$tabid}">{$tablabel}</option>
                    {/foreach}
                </select>
                <div name="tabField" id="tabField" class="lfloat padL10 ModuleFielddiv">
                    <select class="lfloat btn-radius-system" onchange="qrcodeTemplate.fieldSel(this)"><option>{'PLEASESELECTFIELD'|@getFixedLabel}</option></select>
                </div>
                <div class="lfloat padLR10"><input type="text" name="selField" id="selField" class="borderALL btn-radius-system"  style="width:100px;" /></div>
                <input type="button" name="insertHtml" class="createauto" value="{'INSERTINTOPRINTTEMPLATE'|@getFixedLabel}" onclick="qrcodeTemplate.InsertTemplate(this)"/>
            </td>
        </tr>
        <tr>
            <td align="right">
                {'ACONTENTTEMPLATE'|@getFixedLabel}
            </td>
            <td align="left" style="padding: 5px 10px;">
                <textarea id="CKTemplatePrint" name="CKTemplatePrint" type="text/plain" style="width:100%;height:100px;">{$CKEDITORHTML}</textarea>
            </td>
        </tr>
    </table>
</form>
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