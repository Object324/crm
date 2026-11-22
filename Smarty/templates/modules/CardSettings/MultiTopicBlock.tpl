<div id="topictitle" class="DivCR">
    <input type="hidden" value="{$TopicTitleinfo.topicname}"/>
    <table class="settingPopTable" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
            <tr>
                <td width="100" align="right">
                    <font color="red">*</font>标题名称
                </td>
                <td>	
                    <input type="hidden" name="oldtitlename" value="{$TopicTitleinfo.titlename}"/>
                    <input class="controlInput btn-radius-system " name="titlename" tag="{$TopicTitleinfo.topicid}" onchange="CardSettingsobj.topicinputSet(this,'title')" value="{$TopicTitleinfo.titlename}" type="text" >
                </td>
            </tr>
            <tr>
                <td width="100" align="right">
                    二级标题
                </td>
                <td style="">	
                    <input class="detailedViewTextBox"  name="titlecontent" tag="{$TopicTitleinfo.topicid}" onchange="CardSettingsobj.topicinputSet(this,'title')" value="{$TopicTitleinfo.titlecontent}" type="text"
                               onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox bgcolordh'">
                </td>
            </tr>
            {if $TopicTitleinfo.topicname eq 'productData'}
            <tr>
                <td width="100" align="right">
                    {'PICTURE'|@getFixedLabel}
                </td>
                <td style="">	
                    <div name="titelimage" style="display:">
                        <div record="{$TopicTitleinfo.topicid}" >
                            <span  style="display: inline; vertical-align: middle;" >
                                <input type="file" name="titleimagename" tag="title" accept="image/*" onchange="CardSettingsobj.Topicuploadimage(this)" style="opacity:0;position:absolute;cursor: pointer;width: 45px;">
                                <a class="icon-attachment icon-attachments inpb-attachments"></a>
                                {'ADDITION'|@getFixedLabel}
                            </span>
                        </div>
                        <div name="titleimagelists">
                            {foreach key =index  item=$Titleimage from=$Titleimagelists}
                            <div class="attachments-padL10">
                                <a style=" width:250px;text-decoration: none;" href="{$IMAGE_PATH}{$Titleimage.titleimagename}" target="_blank">
                                    <b class="icon-attachment icon-attachments inpb-attachments"></b>
                                    <span class="info" style="color:#333;">{$Titleimage.titleimagename}</span>
                                </a>
                                <span class="webuploadDelbtn" style="padding-left:5px">
                                    <a href="javascript:void(0)" class="attachments-deleted" onclick="CardSettingsobj.Deleteproductimage({$Titleimage.titleimageid})">{'DELETE'|@getFixedLabel}</a>
                                </span>
                            </div>
                            <span class="item" style="padding-left:5px"></span>
                            {/foreach}
                        </div>
                        
                    </div>
                </td>
            </tr>
            {/if}
        </tbody>
    </table>
</div>
<table class="listEntries fir-center listSettingData" name="topicblocklist" id="topicblocklist" border=0 cellspacing=1 cellpadding=0 width="100%">
    <tbody>
    <tr>
        <th>#</th>
        <th style="width:px" tag="1" headermodule="" headername="">图标</th>
        <th style="width:px" tag="2" headermodule="" headername="">小标题</th>
        {if $TopicTitleinfo.topicname neq 'functionData'}
        <th style="width:px" tag="3" headermodule="" headername="">内容</th>
        {/if}
        {if $LANGUAGETYPE eq 'en'}
        <th width="200" tag="4">{'OPERATING'|@getFixedLabel}</th>
        {else}
        <th width="150" tag="4">{'OPERATING'|@getFixedLabel}</th>
        {/if}
    </tr>

    {assign var="i" value=1}
    {foreach key=index item=$topicBlocks from=$TopicBlockLists}
        {assign var="j" value=$i++}
        {assign var="topicid" value=$topicBlocks.topicid}
        {assign var="blockid" value=$topicBlocks.blockid}
        {if $index mod 2 eq '1'}
        <tr id="relation_TopicBlock_{$j}" class="lvtColData" onmouseout="relationListOnMouseOut('TopicBlock_{$j}','on');" onmouseover="relationListOnMouseOver('TopicBlock_{$j}');" style="height:85px;">
        {else}
        <tr id="relation_TopicBlock_{$j}" class="lvtColDataBj" onmouseout="relationListOnMouseOut('TopicBlock_{$j}','On');" onmouseover="relationListOnMouseOver('TopicBlock_{$j}');" style="height:85px;">
        {/if}
        <td>{$j}</td>
        <td class='can-sortable' align="center">
            <div name="cur_blockimagename_{$blockid}" record="{$blockid}" style="">
                {if $j mod 4 eq '0'||$j mod 4 eq '1'}
                    {assign var = 'backgroundcolor' value='#ff6600'}
                {elseif $j mod 4 eq '2'||$j mod 4 eq '3'}
                    {assign var = 'backgroundcolor' value='#fff'}
                {/if}
                <a style=" border:0px solid #000; width:250px;" href="{$topicBlocks.blockimageurl}" target="_blank">
                    <img style="width:80px; height:60px;{if $TopicTitleinfo.topicname eq 'superiorityData'}background-color:{$backgroundcolor}{/if}"  src="{$topicBlocks.blockimageurl}" title="{$topicBlocks.blockimagename}" border="0">
                </a>
                <a href="javascript:;" class="uploadfile" style="display:inline;">{'Select_file'|@getFixedLabel}
                    <input  type="file" tag="block" name="blockimagename_{$blockid}"  accept="image/*" style="height: 20px;width: 80px;" id="blockimagename_{$blockid}" onchange="CardSettingsobj.Topicuploadimage(this)">
                </a>
            </div>
        </td>

        <td align="left">
            <input class="detailedViewTextBox " name="blockname" tag="{$blockid}" onchange="CardSettingsobj.topicinputSet(this,'block')" value="{$topicBlocks.blockname}" type="text" >
        </td>

        {if $TopicTitleinfo.topicname neq 'functionData'}
        <td align="left">
            <input class="detailedViewTextBox" name="blockcontent" tag="{$blockid}" onchange="CardSettingsobj.topicinputSet(this,'block')" value="{$topicBlocks.blockcontent}" type="text" >
        </td>
        {/if}


        <td align="left">
            {if $topicBlocks.presence eq 'yes'}
                <a class="Anu3_a redFont" tag="{$blockid}" name="inactivate" onclick="CardSettingsobj.TopicBlockOperate(this,'inactivate',{$blockid})">{'INACTIVATE'|@getFixedLabel}</a>
            {elseif $topicBlocks.presence eq 'no'}
                <a class="Anu3_a" tag="{$blockid}" name="activate" onclick="CardSettingsobj.TopicBlockOperate(this,'activate',{$blockid})">{'ACTIVATE'|@getFixedLabel}</a>
            {/if}
            <a class="Anu3_a" href="#" tag="{$blockid}" name="delete" onclick="CardSettingsobj.TopicBlockOperate(this,'delete',{$blockid});">{'DELETE'|@getFixedLabel}</a>
        </td>

        </tr>
    {/foreach}
        <tr style="height: 25px;" bgcolor="white">
            {*$TopicTitleinfo.topicid*}
            <td colspan='{if $TopicTitleinfo.topicname neq 'functionData'}5{else}4{/if}' tag="{$TopicTitleinfo.topicname}" align='center'><a onclick="CardSettingsobj.AddtopicBlock(this,{$TopicTitleinfo.topicid})" style="display:inline-block;width:100%;text-align:center;">{'ADDITION'|@getFixedLabel}{'blocks'|@getFixedLabel}</a></td>
        </tr>


    </tbody>
</table>