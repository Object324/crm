{*弹框预览模板文件、*}
<style>
    {literal}
    .imgimgimg:hover{width:295px;}
    .viewpage{
        width:100%;height:100%;top:0;left:0;overflow:hidden;}
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
    {/literal}
</style>
<div class="viewpage">
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
    {elseif $type eq 'kkFileView'}
        <div style="margin-left:50px; height:95%">
            <iframe  id='iframepage' src='{$kkFileViewUrl}' width='100%' height='96%' frameborder='0'></iframe>
        </div>
    {elseif $type eq 'other'}
        <div style="margin-left:50px">
            <img hspace="3" border="0" align="absmiddle" title="{$name}" alt="{$name}" class="imgimgimg" src="themes/images/othet.jpg"><br /><br />
            {$name}
        </div>
    {/if}
</div>
