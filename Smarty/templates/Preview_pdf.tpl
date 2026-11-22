<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
    <meta name="author" content="phpadmin" />
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
    {* 弹框预览时，不需要重新加载CrmPopup.js*}
    {if $inpopup neq 'yes'}
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
    {/if}
    <script type="text/javascript" language="JavaScript">
        var ld = $;
        var global_js_url='{$JSURL}';
        var frommodule='{$FROMMODULE}';
        var popupobj=new Object();
        popupobj.module=frommodule;
        CrmPopup.global_listPopupObj.push(popupobj);

    </script>
    <!---知识管理，预??>下载次数字段-->
    <script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js"></script>
    <script type='text/javascript' src='{$JSURL}include/js/modules/Reminds/Reminds.js' language="javascript"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>

    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Attachment/Attachment.js"></script>
    <style type="text/css">@import url("themes/softed/global.css");</style>
    <title>{'Attachment'|@getFixedLabel}{'PREVIEW'|@getFixedLabel}-{$name}</title>
    <style>
        html,body{
            height:100%;
            width: 100%;
            overflow:hidden;
            margin:0;
            padding: 0;
        }

        {literal}
        .imgimgimg:hover{width:295px;}
        .viewpage{
            /*position:absolute;*/
            width:100%;height:100%;top:0;left:0;overflow:hidden;}
        .menu_side{
            position: absolute;
            right: -300px;
            top: 43px;
            bottom: 0;
            z-index: 2;
            width: 300px;
            background: #fff;
            overflow: hidden;
            overflow-y: auto;
            border-left: 1px solid #e5e5e5;
            box-shadow: 0 0 15px #000;
            -webkit-box-shadow:-4px 0 6px rgba(0,0,0,.08);
            -webkit-transition:all 0.5s ease;
            -moz-transition:all 0.5s ease;
        }
        .maintext{
            position: absolute;
            width: 100%;
            height: 100%;
            left: 0px;
            top:43px;
            margin: auto;
            display: flex;
            align-items: center;
            justify-content: center;
            -webkit-transition:all .3s linear;
        }
        .maintext img{
            max-width: 80%;
            max-height: 80%;
            margin-top:-20px;
        }
        .pv_ico{
            display: inline-block;
            background-image: url(themes/softed/images/viewbtn.png);
            background-repeat: no-repeat;
            width: 44px;
            height: 44px;
            cursor: pointer;
        }
        .pv_ico_full{
            background-position: -275px 11px;
            vertical-align: middle;
        }
        .pv_ico_next{
            background-position: -228px 11px;
            vertical-align: middle;
        }
        .pv_ico_nonext{
            background-position: -228px -85px;
            vertical-align: middle;
        }
        .pv_ico_prev{
            background-position: -184px 11px;
            vertical-align: middle;
        }
        .pv_ico_noprev{
            background-position: -184px -85px;
            vertical-align: middle;
        }
        .pv_ico_down{
            background-position: -134px 11px;
            vertical-align: middle;
        }
        .viewbtn{margin-left:20px;height: 42px;line-height: 42px;border-bottom: 1px solid #e5e5e5;}
        .viewbtn a{float:right;width:44px;height:44px;margin:0px 10px;}
        .menu_close{height: 42px;line-height: 42px;padding: 0 10px;border-bottom: 1px solid #ddd;}
        .menu_side .menu_list{list-style: none;margin: 0px;padding: 0px;width: 100%;}
        .menu_side .menu_list li{
            list-style-type: none;
            float: none;
            width: auto;
            border-radius: 0;
            border-bottom: 1px solid #ddd;
            margin: 0;
            padding: 8px 10px;
            height: auto;
        }
        .menu_side .menu_list li a{
            text-decoration:none;
            color: #545454;
        }
        {/literal}
    </style>
</head>

<body>
<div class="viewpage">
    {if $isPop!="yes"}
    <div class="viewbtn">
        <span><b style="font-size:27px">{$name}</b></span>
        <a href="javascript:setMore()" title="更多">
            <b class="pv_ico pv_ico_full"></b>
        </a>
        {if $NEXT_STAT eq 'yes'}
            <a  href="index.php?module=uploads&action=Preview_pdf&ReportHeader=DHeader&record={$entityid}&fileId={$NEXT_ATTACHID}&frommodule={$FROMMODULE}" title="下一个"><b class="pv_ico pv_ico_next"></b></a>
        {else}
            <a href="javascript:void(0);" title="下一个"><b class="pv_ico pv_ico_nonext"></b></a>
        {/if}
        {if $PRE_STAT eq 'yes'}
            <a href="index.php?module=uploads&action=Preview_pdf&ReportHeader=DHeader&record={$entityid}&fileId={$PRE_ATTACHID}&frommodule={$FROMMODULE}" title="上一个"><b class="pv_ico pv_ico_prev"></b></a>
        {else}
            <a href="javascript:void(0);" title="上一个"><b class="pv_ico pv_ico_noprev"></b></a>
        {/if}

        {if $FROMMODULE eq 'Emails'}
            <a  href="index.php?module=Emails&action=EmailsAjax&file=emailfiledownload&filename={$FILENAME}&mailrecordid={$MAILINFO->mailrecordid}">{'DOWNLOADFILE'|@getFixedLabel}</a>
        {else if $mode eq '1'}
            <a  onclick="javascript:dldCntIncrease({$fileId});" title="{'DOWNLOADFILE'|@getFixedLabel}" href="index.php?module=uploads&action=downloadfile&entityid={$entityid}&fileid={$fileId}">{'DOWNLOADFILE'|@getFixedLabel}</a>
        {else if $entityid|IsDownLoadProfile:$FROMMODULE eq 'yes'}
            <a  href="javascript:DownLoad({$fileId},{$entityid})" title="{'DOWNLOADFILE'|@getFixedLabel}" title="{'DOWNLOADFILE'|@getFixedLabel}"><b class="pv_ico pv_ico_down"></b></a>
        {/if}
    </div>
    {/if}
    {if $type eq 'text'}
        {$content}
    {elseif $type eq 'img'}
        <div class="maintext">
            <img hspace="3" border="0" align="absmiddle" id="img_id" title="{$name}" alt="{$name}" src="{$img_src}" class="mainfield">
        </div>
    {elseif $type eq 'application/msword'}
        <div style="margin-left:50px; height:95%">
            <iframe  id='iframepage' src='https://view.officeapps.live.com/op/embed.aspx?src={$ATTACHMENTURL}' width='100%' height='96%' frameborder='0'></iframe>
        </div>
    {elseif $type eq 'excel'||$type eq 'xls'||$type eq 'xlsx'}
        <div style="margin-left:50px">
            <img hspace="3" border="0" align="absmiddle" title="{$name}" alt="{$name}" src="themes/images/excel.png"><br /><br />
            {$name}
        </div>
    {elseif $type eq 'ppt'}
        <div style="margin-left:50px">
            <img hspace="3" border="0" align="absmiddle" title="{$name}" alt="{$name}" src="themes/images/powerpoint.png"><br /><br />
            {$name}
        </div>
    {elseif $type eq 'pdf'}
        <div >
            {if $pdfname neq ''}
                <iframe src= "{$filepah}{$pdfname}" width= "100%"   height= "800px" id="frame"> </iframe>
            {else}
                {if $storage_location eq 'cos'}
                    <iframe src= "{$filepah}" width= "100%"   height= "800px" id="frame"> </iframe>
                {else}
                    <iframe src= "{$filepah}{$replace_filename}" width= "100%"   height= "800px" id="frame"> </iframe>
                {/if}
            {/if}
        </div>
    {elseif $type eq 'rar'}
        <div style="margin-left:50px">
            <img hspace="3" border="0" align="absmiddle" title="{$name}" alt="{$name}" src="themes/images/winrar.jpg"><br /><br />
            {$name}
        </div>
    {elseif $type eq 'other'}
        <div style="margin-left:50px">
            <img hspace="3" border="0" align="absmiddle" title="{$name}" alt="{$name}" class="imgimgimg" src="themes/images/othet.jpg"><br /><br />
            {$name}
        </div>
    {/if}
    {if $isPop!="yes"}
    <div id="div_more" class="menu_side" style="margin-right:0px;">
        <div class="menu_close">{'Attachment'|@getFixedLabel}({$ATT_NUM_ROWS}{'GECOUNT'|@getFixedLabel})
        </div>
        <ul class="menu_list">
            {foreach item=att_name key=attachmentid from=$ATT_DATA}
                <li>
                    <a href="index.php?module=uploads&action=Preview_pdf&ReportHeader=DHeader&record={$entityid}&fileId={$attachmentid}&frommodule={$FROMMODULE}" title="{$att_name}">{$att_name}</a>
                </li>
            {/foreach}
        </ul>
    </div>
    {/if}
</div>
</body>
<script>
    {literal}
    function setMore(){
        if(ld('#div_more') != undefined){
            if(ld('#div_more').css('margin-right') == '300px'){
                ld('#div_more').css('margin-right','0px');
                ld('.maintext').css('left','0px');
            } else{
                ld('#div_more').css('margin-right','300px');
                ld('.maintext').css('left','-150px');
            }
        }
    }
    var height = ld(document).height();
    height = height - 43;
    ld('#frame').css('height',height+"px");
    {/literal}
</script>
</html>