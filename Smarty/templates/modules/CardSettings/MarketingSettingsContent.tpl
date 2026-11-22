<div class="">	
    <table border=0 cellspacing=1 cellpadding=0 width=100% class="ControlTable1 listEntries fir-center listSettingData">
        <tr>
          	<th>#</th>
            <th width="15%" title="{'NavigationPicture'|@getFixedLabel}">按钮图片</th>
            <th width="20%" title="{'NavigationLinkType'|@getFixedLabel}">按钮名称</th>
            <th title="{'WHETHERTODISPLAY'|@getFixedLabel}">体验链接</th>
            <th width="230px">{'OPERATING'|@getFixedLabel}</th>
        </tr>
        
        {assign var="i" value=0}
        {assign var="maxcount" value = $MarketingInfo|@count}
		{foreach name=printlist item=listinfo from=$MarketingInfo}
            {assign var="printlistNum" value=$smarty.foreach.printlist.iteration }
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" style="height:85px;">
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));"style="height:85px;">
            {/if}
    		<td>{$printlistNum}</td>

            <td align="center">
                {assign var="imagepath" value=$IMAGE_PATH|cat:$listinfo.btn_image}
                {if $listinfo.btn_image eq ''}
                    {if $listinfo.btn_name eq 'linkus'}
                        {assign var="imagepath" value="http://www.71mis.cn/wx_images/cloud/contact.png"}
                    {elseif $listinfo.btn_name eq 'shardchard'}
                        {assign var="imagepath" value="http://www.71mis.cn/wx_images/cloud/share.png"}
                    {elseif $listinfo.btn_name eq 'experience'}
                        {assign var="imagepath" value="http://www.71mis.cn/wx_images/cloud/home_kefu_2021_8_31.png"}
                    {elseif $listinfo.btn_name eq 'addwechat'}
                        {assign var="imagepath" value="http://www.71mis.cn/wx_images/cloud/weixin.png"}
                    {/if}
                {/if}
                <div name="cur_btn_image{$listinfo.id}" record="{$listinfo.id}" style="">
                    <a style=" border:0px solid #000; width:250px;" href="{$imagepath}" target="_blank">
                        <img style="width:60px; height:60px;" src="{$imagepath}" title="{$listinfo.btn_image}" border="0">
                    </a>
                </div>
                <div name="div_btn_image{$listinfo.id}" style="display: none;" >
{*                    <input class="detailedViewTextBox" style="width:150px;float:left;" type="text" value="{$listinfo.btn_image}" maxlength="100" name="btn_image{$listinfo.id}">*}
                    <a href="javascript:;" class="uploadfile" style="display:inline;">{'Select_file'|@getFixedLabel}
                        <input type="file" name="btn_image{$listinfo.id}" accept="image/*" id="btn_image{$listinfo.id}" onchange="CardSettingsobj.validateFilename(this)">
                    </a>
                    <span class="info" name="span_btn_image{$listinfo.id}" style="padding-left:5px;"></span>
                </div>
    		</td>
    	 	<td>
                <div name="cur_btn_label{$listinfo.id}" title="{$listinfo.btn_label}">{$listinfo.btn_label}</div>
                <div name="div_btn_label{$listinfo.id}" style="display: none;" >
                    <input class="detailedViewTextBox" style="width:150px;float:left;" type="text" value="{$listinfo.btn_label}" maxlength="100" name="btn_label{$listinfo.id}">
                </div>
    		</td>
    		<td>
                <div name="cur_link_url{$listinfo.id}" title="{$listinfo.link_url}" style="text-align: center;">
                    {if $listinfo.btn_name eq 'experience'}
                        {$listinfo.link_url}
                    {else}
                        <font class="oragleFont"><span id="visible_no" title="{'NO'|@getFixedLabel}">{'NO'|@getFixedLabel}</span></font>
                    {/if}
                </div>
                <div name="div_link_url{$listinfo.id}" style="display: none;">
                    {if $listinfo.btn_name eq 'experience'}
                    <input class="detailedViewTextBox" style="width:246px;display:inline-block;" type="text" value="{$listinfo.link_url}" maxlength="200" name="link_url{$listinfo.id}">
                    {/if}
                    <div style="display:inline-block;margin-left:5px;">
                        <a class="Anu3_a" href="javascript:void(0);" onclick="CardSettingsobj.MarketingEditSave(this,{$listinfo.id},'{$listinfo.btn_name}')">保存</a>
                        <a class="Anu3_a redFont" href="javascript:void(0);" onclick="CardSettingsobj.MarketingShowEditInput(this,'cancel',{$listinfo.id},'{$listinfo.btn_name}');">取消</a>
                    </div>
                </div>
    		</td>
            <td>
			  	<a class="Anu3_a" href="#" tag="{$listinfo.id}" onclick="CardSettingsobj.MarketingShowEditInput(this,'edit',{$listinfo.id},'{$listinfo.btn_name}');" name="edit">{'EDIT'|@getFixedLabel}</a>
{*                <a class="Anu3_a redFont" tag="{$listinfo.id}" name="delete" onclick="CardSettingsobj.MarketingOperate(this,'delete',{$listinfo.id})">{'DELETE'|@getFixedLabel}</a>*}
                {if $listinfo.presence eq 'yes'}
                    <a class="Anu3_a redFont" tag="{$listinfo.id}" name="inactivate" onclick="CardSettingsobj.MarketingOperate(this,'inactivate',{$listinfo.id})">{'INACTIVATE'|@getFixedLabel}</a>
                {elseif $listinfo.presence eq 'no'}
                    <a class="Anu3_a" tag="{$listinfo.id}" name="activate" onclick="CardSettingsobj.MarketingOperate(this,'activate',{$listinfo.id})">{'ACTIVATE'|@getFixedLabel}</a>
                {/if}
                <a class="Anu3_a" tag="{$listinfo.id}" {if $printlistNum eq 1} style="display:none;" {/if} name="moveup" onclick="CardSettingsobj.MarketingOperate(this,'moveup',{$listinfo.id})">{'MOVEUP'|@getFixedLabel}</a>
                <a class="Anu3_a" tag="{$listinfo.id}" {if $printlistNum eq $maxcount}style="display:none;"{/if} name="movedown" onclick="CardSettingsobj.MarketingOperate(this,'movedown',{$listinfo.id})">{'MOVEDOWN'|@getFixedLabel}</a>
		    </td>
	    </tr>
	    {/foreach}
	</table>
</div>