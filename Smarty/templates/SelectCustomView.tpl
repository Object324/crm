<div class="shujufenlei" id="showCustomlist">
{assign var=fldname value='selectcustomview'}
{if $RELMODULE neq ''}
    {assign var=custom_module value=$RELMODULE}
	<select name="{$fldname}_{$custom_module}" onchange="DetailViewRelation.setRelatedListCustomView (event,ld(this))"  id="{$fldname}_{$custom_module}" style="display:none">
{else}
	{assign var=custom_module value=$MODULE}
	<select onchange="SmOwnerSearchScopeChange(this,'{$custom_module}','{$CATEGORY}')" id="{$fldname}_{$custom_module}" name="{$fldname}_{$custom_module}" style="display:none">
{/if}

    {foreach key=User_Key item=custom_info from=$CUSTOMVIEW_OPTION}
		{if $VIEWID eq $custom_info.cvid}
			{assign var=optText value=$custom_info.viewname}
			<option value="{$custom_info.cvid}" selected="true">{$custom_info.viewname}</option>
		{else}
			<option value="{$custom_info.cvid}">{$custom_info.viewname}</option>
		{/if}
	{/foreach}

    </select>

    <div name="dv_chzn_{$fldname}_{$custom_module}" class="chzn-container chzn-container-single"  onMouseLeave="cmb_mouseleave(event,'{$fldname}_{$custom_module}','showCustomlist')">
{*        @edit:liushuai,2020-10-20,reason:0042942: （https://61mis.com/kfbtest/ [^]）销售机会单据列表界面，点击“客户名称”进入客户单据查看详情，点击相关信息->销售机会列表界面的“数据分类”下拉框，销售机会列表界面数据分类下拉选项也被展开了(去掉第三个参数showCustomlist)*}
{*        // @edit:dong @date:2020/11/09 @reason:数据分类转化的自定义链接模块不可下拉*}
        <a style="min-width:125px;width:auto;padding-right:20px;" class="chzn-single" {if !$LINKMODULECUSTOM} onclick="com_img_change(event,'{$fldname}_{$custom_module}','showCustomlist')" {/if} href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}_{$custom_module}">
			<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 105px;margin-left: -10px;border-style:none;margin-top: -1px;"
                   title="{$optText}" tabindex="0"  name='cmb_span_optiontext_{$fldname}_{$custom_module}' onclick="cmb_picklist_end_foucs(event,'{$fldname}_{$custom_module}','showCustomlist')" onKeyUp="com_chosen(event,'{$fldname}_{$custom_module}','showCustomlist')" value="{$optText}">
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;padding-right:5px; top: 30px;z-index:902;width: 100%;" class="chzn-drop" name='dv_drop_{$fldname}_{$custom_module}' >
            <ul class="chzn-results" name="cmb_ul_{$fldname}_{$custom_module}" style="float:none;">
				{assign var="i" value=0}{assign var="j" value=0}{assign var="k" value=0}
    			{foreach key=User_Key item=custom_info from=$CUSTOMVIEW_OPTION}
                    {if $custom_info.popup eq 'popup'}
                        <li class="active-result" style="float:none;padding: 0 7px 0 7px;line-height:26px;height: auto;" name="dv_chzn_{$i }_{$fldname}_{$custom_module}" data-customlabel="{$custom_info.viewname}" onclick="showDefaultCustomViewPopup(this,'{$custom_info.module}','','{$custom_info.cvid}')" onmouseover="cmb_limouseover(event,'{$fldname}_{$custom_module}','showCustomlist')">{$custom_info.viewname}</li>
						{assign var="i" value=$i+1}<!--i、j、k 需要区分开，不然同个页面2个下拉控件鼠标移上去背景会有问题-->
                    {elseif $custom_info.popup eq 'relatedleft'}
                        <li class="active-result" style="float:none;padding: 0 7px 0 7px;line-height:26px;height: auto;" related_cvid="{$custom_info.cvid}" relateTag="{$custom_module}" relatedid="{$custom_info.relationId}" name="dv_chzn_{$j }_{$fldname}_{$custom_module}" onclick="DetailViewRelation.setRelatedListCustomView(event,ld(this))" onmouseover="cmb_limouseover(event,'{$fldname}_{$custom_module}','showCustomlist')">{$custom_info.viewname}</li>
						{assign var="j" value=$j+1}
                    {else}
                        <li class="active-result" style="float:none;padding: 0 7px 0 7px;line-height:26px;height: auto;" name="dv_chzn_{$k }_{$fldname}_{$custom_module}" data-customlabel="{$custom_info.viewname}" onclick="showDefaultCustomView(this,'{$custom_info.module}','','{$custom_info.cvid}')" onmouseover="cmb_limouseover(event,'{$fldname}_{$custom_module}','showCustomlist')">{$custom_info.viewname}</li>
						{assign var="k" value=$k+1}
                    {/if}
    			{/foreach}
                <li style="" class="" name="li_chzn_{$fldname}_{$custom_module}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
			</ul>
	    </div>
    </div>
</div>