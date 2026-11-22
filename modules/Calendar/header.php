<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

$category = getParentTab();
global $theme,$app_strings,$mod_strings;
global $CALENDAR_DISPLAY, $WORLD_CLOCK_DISPLAY, $CALCULATOR_DISPLAY, $CHAT_DISPLAY;

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
//$check_button = Button_Check('Calendar');//by kevin get button Profiles
/*
$html_string = '<div class="ChildBotton">
<ul>
<li class="Name"><a href="index.php?action=index&module=Calendar&parenttab=My Home Page">'.getTranstab('Calendar').'</a></li><li>';
if($check_button['Create']=='yes')
 $html_string .='<a class="Anu0_a" title="'.getFixedLabel('CREATE').'" href="index.php?module=Calendar&action=EditView&return_module=Calendar&return_action=DetailView&activity_mode=Events&&parenttab=My Home Page&Create=true">
 <img src="themes/softed/button/icon_add0.png" /><span>'.getFixedLabel('CREATE').'</span></a>';
 else
 $html_string .='<a class="Anu0_a" href="index.php?module=Calendar&action=EditView&return_module=Calendar&return_action=DetailView&activity_mode=Events&&parenttab=Home&Create=true">
 <img src="themes/softed/button/icon_add0.png" /><span>'.getFixedLabel('CREATE').'</span></a>';
 $html_string .='</li>
 <li>
 <a class="Anu0_a Anu0B" href="javascript:;">
 <img src="themes/softed/button/icon_search_black.png" /><span>'.getFixedLabel('SEARCH').'</span></a>
 </li>'; 
if($CALENDAR_DISPLAY == 'true') 
        $html_string .= '<li><a class="Anu0_a" title="'.getFixedLabel('CANENDAR').'" href="javascript:;" onClick=\'fnvshobj(this,"miniCal");getMiniCal("parenttab='.$category.'");\'><img src="themes/softed/button/icon_calendar.png" /><span>'.getFixedLabel('CANENDAR').'</span></a></li>'; 
if($WORLD_CLOCK_DISPLAY == 'true') 
        $html_string .= '<li><a class="Anu0_a" title="'.getFixedLabel('CLOCK').'" href="javascript:;" onClick="fnvshobj(this,\'wclock\');"><img src="themes/softed/button/icon_clock.png" /><span>'.getFixedLabel('CLOCK').'</span></a></li>'; 
if($CALCULATOR_DISPLAY == 'true') 
        $html_string .= '<li><a class="Anu0_a" onClick="fnvshobj(this,\'calculator_cont\');fetch_calc();"> <img src="themes/softed/button/icon_calculator.png" /><span>'.getFixedLabel('CALCULATORS').'</span></a></li>'; 
if($CHAT_DISPLAY == 'true') 
        $html_string .= '<li><a class="Anu0_a" href="javascript:;" onClick=\'return window.open("index.php?module=Home&action=vtchat","Chat","width=600,height=450,resizable=1,scrollbars=1");\' title="'.getFixedLabel('CHAT').'"><img src="themes/softed/button/icon_say.png" border=0><span>'.getFixedLabel('CHAT').'</span></a></li>'; 
if($LAST_READ == 'true')  
        $html_string .= '<li><a class="Anu0_a" onClick="fnvshobj(this,\'tracker\');" title="'.getFixedLabel('READEN').'"><img src="themes/softed/button/icon_see.png" ><span>'.getFixedLabel('READEN').'</span></a></li>
<li><a class="Anu0_a Anu0B"><img src="themes/softed/button/icon_rk_black.png" /><span>'.getFixedLabel('IMPORT').'</span></a></li>
<li><a name=\'import_link\' class="Anu0_a Anu0B"> <img src="themes/softed/button/icon_ck_black.png" /><span>'.getFixedLabel('EXPORT').'</span></a></li>';
if((isPermitted('Settings','index') == 'yes'))
	$html_string .= '<li><a class="Anu0_a" title="'.getFixedLabel('SETTINGS').'" href="index.php?module=Settings&action=LayoutBlockList&parenttab=Settings&formodule=Calendar">
                    <img src="themes/softed/button/icon_set0.png" /><span>'.getFixedLabel('LBL_PAGE_SET').'</span></a>
                    </li>';
$html_string .= '
	</ul>
    </div>';
*/  
$html_string = '	<table border=0 cellspacing=0 cellpadding=0 width=100% align=center>
	     <tr>
		     <td valign="top" width=100% >
			
			<!-- Calendar Tabs starts -->
			<div class="small" >
			<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">
		         <tr>
					<td>
                        <!--切换导航-->
                        <div class="Tab_div Tab_divBjtop">
                   	    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                          <tr>
                            <td valign="top" class="L">
                            	<ul>
                                	<li><a class="On" href="###">'.getFixedLabel('CALENDARVIEW').'</a></li>
                                    <li><a href="index.php?action=ListView&module=Calendar&parenttab='.$category.'">'.getFixedLabel('LISTVIEW').'</a></li>
                                </ul>
                            </td>
                          </tr>
                        </table>
                        </div>
                        <!--切换导航  end-->
					</td>
				</tr>
				<tr>
					<td align="left" valign="top">
						<table class="dvtContentSpace" border="0" cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td align="left">
								<!-- content cache -->
									<table border="0" cellpadding="0" cellspacing="0" width="100%">
									<tr>
										<td>
	';
	echo $html_string;
?>	