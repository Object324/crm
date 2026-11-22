{*修改编码格式:统一编码：UTF-8*}


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
        {assign var='bigtype' value=$maindata['bigtype']}
        {assign var='relatedmodulefield' value=$maindata['relatedmodulefield']}
		{*wsh 标签颜色*}
		{assign var='label_style' value=$maindata['label_style']}
		{*zxm 20211230字段颜色 字段说明样式*}
        {assign var='fieldvaluecolor' value=$maindata['fieldvaluecolor']}
        {assign var='fieldplaceholder' value=$maindata['fieldplaceholder']}
        {assign var='value_name' value=$maindata['value_name']}
        {assign var='value_name_show' value=$maindata['value_name_show']}

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
		{* 工商查询 *}
		{assign var = "BUSINESSQUERY" value = $maindata['businessquery']}{* 是否为工商查询字段 *}
		{assign var = "ENABLEBUSINESS" value = $maindata['isenablebusiness']}{* 是否启用工商查询 *}
		{assign var = "BUSINESSFUZZYQUERY" value = $maindata['isenablebusinessfuzzyquery']}{* 是否启用工商模糊查询 *}
		{assign var='helptips' value=$maindata['helptips']}

		{include file="DetailView/EditViewUIContent.tpl"}
        