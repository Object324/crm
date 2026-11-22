<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/colpick/colpick.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/colpick/plugin.js?v={$GLOBALMINVERSION}"></script>
<link rel="stylesheet" type="text/css" href="{$CSS}themes/softed/Homeboard.css?v={$GLOBALMINVERSION}"/>
<div class="skincustom" style="height:472px;">
	{*页签*}
	<div class="salestarget-tab" style="margin: 15px;width:calc(100%-30px)"></div>
	{*预设外观*}
	<div class="settingPopTable settingPopTableNoBot" data-setting="preset_appearance" style="{if $MENUSTYLE=='custom'}display: none{/if}" border="0" cellpadding="0" cellspacing="0" width="100%">
		<div class="menu-settingimg">
			<div name="menustyle_dark" menustyle="dark" class="textacenter {if $MENUSTYLE eq 'dark'}checkMenuStyle{/if}">
				<div style="padding: 8px;color: #999;">{'businessblue'|@getFixedLabel}</div>
				<div class="menudark">
					<img src="{$IMAGEURL}themes/leftimages/blue.png?v={$GLOBALMINVERSION}" border="0" style="width: 100%;height: 100%;">
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
			<div name="menustyle_lightcolour" menustyle="lightcolour" class="textacenter {if $MENUSTYLE eq 'lightcolour'}checkMenuStyle{/if}">
				<div style="padding: 8px;color: #999;">{'simplewhite'|@getFixedLabel}</div>
				<div class="menulight">
					<img src="{$IMAGEURL}themes/leftimages/white.png?v={$GLOBALMINVERSION}" border="0" class="widhei100">
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
		</div>
		<div class="menu-settingimg">
			<div name="menustyle_red" menustyle="red" class="textacenter {if $MENUSTYLE eq 'red'}checkMenuStyle{/if}">
				<div style="padding: 8px;color: #999;">{'festivalred'|@getFixedLabel}</div>
				<div class="menudark">
					<img src="{$IMAGEURL}themes/leftimages/red.png?v={$GLOBALMINVERSION}" border="0" style="width: 100%;height: 100%;">
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
			<div name="menustyle_black" menustyle="black" class="textacenter {if $MENUSTYLE eq 'black'}checkMenuStyle{/if}">
				<div style="padding: 8px;color: #999;">{'midnightblack'|@getFixedLabel}</div>
				<div class="menulight">
					<img src="{$IMAGEURL}themes/leftimages/black.png?v={$GLOBALMINVERSION}" border="0" class="widhei100">
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
		</div>
	</div>
	{*预设背景色*}
	<div class="settingPopTable settingPopTableNoBot" data-setting="preset_background" style="display: none" border="0" cellpadding="0" cellspacing="0" width="100%">
		<div class="menu-settingimg">
			<div name="menubackground_bg1" background="bg1" class="textacenter {if $BACKGROUND eq '#F2F5FB' || ($BACKGROUND neq '#E4E7ED' && $BACKGROUND neq '#EBEEF4' && $BACKGROUND neq '#DDDFE5')}checkMenuStyle{/if}">
				<div style="padding: 8px;color: #999;">{'backgroundone'|@getFixedLabel}</div>
				<div class="menudark">
					<img src="{$IMAGEURL}themes/leftimages/bg1.png?v={$GLOBALMINVERSION}" border="0" style="width: 100%;height: 100%;">
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
			<div name="menubackground_bg2" background="bg2" class="textacenter {if $BACKGROUND eq '#E4E7ED'}checkMenuStyle{/if}">
				<div style="padding: 8px;color: #999;">{'backgroundtwo'|@getFixedLabel}</div>
				<div class="menulight">
					<img src="{$IMAGEURL}themes/leftimages/bg2.png?v={$GLOBALMINVERSION}" border="0" class="widhei100">
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
		</div>
		<div class="menu-settingimg">
			<div name="menubackground_bg3" background="bg3" class="textacenter {if $BACKGROUND eq '#EBEEF4'}checkMenuStyle{/if}">
				<div style="padding: 8px;color: #999;">{'backgroundthree'|@getFixedLabel}</div>
				<div class="menudark">
					<img src="{$IMAGEURL}themes/leftimages/bg3.png?v={$GLOBALMINVERSION}" border="0" style="width: 100%;height: 100%;">
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
			<div name="menubackground_bg4" background="bg4" class="textacenter {if $BACKGROUND eq '#DDDFE5'}checkMenuStyle{/if}">
				<div style="padding: 8px;color: #999;">{'backgroundfour'|@getFixedLabel}</div>
				<div class="menulight">
					<img src="{$IMAGEURL}themes/leftimages/bg4.png?v={$GLOBALMINVERSION}" border="0" class="widhei100">
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
		</div>
	</div>
	{*自定义*}
	<div class="settingPopTable settingPopTableNoBot" data-setting="custom_appearance" style="{if $MENUSTYLE!='custom'}display: none{/if}" border="0" cellpadding="0" cellspacing="0" width="100%">
		<div class="menucustomstyle" name="tr_menuback" style="margin-top:20px;">
			<div class="menubackstyle" style="">{'MENUBACKGROUNDCOLOR'|@getFixedLabel}</div>
			<div style="position: relative;">
				<input type="text" class="txtBox btn-radius-system color_inputtxt" name="input_menuback"  id="colorPicker" value="{$MENUBACK}">
				<div tag="menuback" class="choosed_color btn1 flex_align" style="background: {$MENUBACK};" name="div_menuback"></div>
				<a href="javascript:void(0);" class="marL10 restoreclor" name="defaultcolpick_menuback" tag="menuback" onclick="defaultColpick(\'menuback\')"><b></b>{'RESTORETHEDEFAULT'|@getFixedLabel}</a>
			</div>
		</div>
		<div class="menucustomstyle" name="tr_menuhover" >
			<div class="menubackstyle">{'MENUSELECTBACKGROUNDCOLOR'|@getFixedLabel}</div>
			<div style="position: relative;">
				<input type="text" class="txtBox btn-radius-system color_inputtxt" value="{$MENUHOVER}" name="input_menuhover">
				<div tag="menuhover" class="choosed_color btn2" style="background: {$MENUHOVER};" name="div_menuhover"></div>
				<a href="javascript:void(0);" name="defaultcolpick_menuhover" onclick="defaultColpick(\'menuhover\')" tag="menuhover" class="marL10 restoreclor"><b></b>{'RESTORETHEDEFAULT'|@getFixedLabel}</a>
			</div>
		</div>
		<div class="menucustomstyle" name="tr_menufont" >
			<div class="menubackstyle">{'menuselectionfontcolor'|@getFixedLabel}</div>
			<div style="position: relative;">
				<select class="commonSelectPop overflow-space" name="input_menufont">
					<option value="FFFFFF" {if $MENUFONT eq '#FFFFFF'}selected{/if}>{'simplewhite'|@getFixedLabel}</option>
					<option value="3B4859" {if $MENUFONT eq '#3B4859'}selected{/if}>{'midnightblack'|@getFixedLabel}</option>
				</select>
			</div>
		</div>
		<div class="menu-settingimg" style="padding-top: 5px;">
			<div name="menustyle_custom" menustyle="custom" class="textacenter {if $MENUSTYLE eq 'custom'}checkMenuStyle{/if}">
				<div class="menudark">
					<div id="colorPreview" class="overlay" style="background-color:{$MENUBACK};"></div>
					<img id="prevImage" style="z-index:0;width: 100%;height: 100%;" src="{$IMAGEURL}themes/leftimages/BG.png?v={$GLOBALMINVERSION}" border="0" >
					<span class="bingo"><i class="bingocheck"></i></span>
				</div>
			</div>
		</div>
	</div>
</div>
