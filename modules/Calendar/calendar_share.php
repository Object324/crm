<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
global $current_user,$mod_strings,$app_strings;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
require_once('include/database/PearDatabase.php');
require_once('modules/Calendar/CalendarCommon.php');
 $t=Date("Ymd");
 $userDetailsall=getSharingUserName($current_user->id);//$userDetails
 $shareduser_ids = getSharedUserId($current_user->id);
 $userDetails=array_diff($userDetailsall,$shareduser_ids);
?>

<form name="SharingForm" method="post" action="index.php" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Calendar">
<input type="hidden" name="action" value="updateCalendarSharing">
<input type="hidden" name="view" value="<?php echo vtlib_purify($_REQUEST['view']) ?>">
<input type="hidden" name="hour" value="<?php echo vtlib_purify($_REQUEST['hour']) ?>">
<input type="hidden" name="day" value="<?php echo vtlib_purify($_REQUEST['day']) ?>">
<input type="hidden" name="month" value="<?php echo vtlib_purify($_REQUEST['month']) ?>">
<input type="hidden" name="year" value="<?php echo vtlib_purify($_REQUEST['year']) ?>">
<input type="hidden" name="viewOption" value="<?php echo vtlib_purify($_REQUEST['viewOption']) ?>">
<input type="hidden" name="subtab" value="<?php echo vtlib_purify($_REQUEST['subtab']) ?>">
<input type="hidden" name="parenttab" value="<?php echo vtlib_purify($_REQUEST['parenttab']) ?>">
<input type="hidden" name="current_userid" value="<?php echo $current_user->id ?>" >
<input type="hidden" name="shar_userid" id="shar_userid" >

    
    <div class="D_pop_tit">
    	<strong class="D_ptita"><?php echo getFixedLabel('SETTINGAGENDA')?></strong>
        <a href="javascript:fninvshnew('calSettings');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="<?php getFixedLabel('CLOSE'); ?> " title="<?php getFixedLabel('CLOSE'); ?>"/>
        </a>
    </div>		
    <div class="Content_div">
    	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
          <tr>
            <td class="Note">
				<ul class="LdPop_ul2 LdPop_ul2Bor" style="padding-left:0px;">
				<li class="A">
                    <img src="<?php echo lingdang_imageurl('cal_clock.jpg', $theme)  ?>" >
                    <span><?php echo getFixedLabel('SETTINDATE')?></span>
                </li>
				<li class="B" style="line-height: 22px;">
                    <input type="checkbox" name="sttime_check" <?php if($current_user->start_hour != ''){?> checked <?php } ?> onClick="enableCalstarttime();">
                    <label><?php echo getFixedLabel('SCHEDULESTARTTIME')?> </label>
				    <select name="start_hour" <?php if($current_user->start_hour == ''){?>disabled <?php } ?> >
					<?php
						for($i=0;$i<=23;$i++)
						{
							if($i == 0)
								$hour = "12:00 am";
							elseif($i >= 12)
							{
								if($i == 12)
									$hour = $i;
								else 
									$hour = $i - 12;
									$hour = $hour.":00 pm";
							}
							else{
									$hour = $i.":00 am";
								}
							if($i <= 9 && strlen(trim($i)) < 2)
							{
								$value = '0'.$i.':00';
                       		}
							else
								$value = $i.':00';
							if($value === $current_user->start_hour)
								$selected = 'selected';
                             else
								$selected = '';
					?>	
					<option <?php echo $selected?> value="<?php echo $value?>"><?php echo $hour?></option>
					<?php
						}
					?>
					</select>
                    </li>
					<li>
                    <input type="checkbox" name="hour_format" <?php if($current_user->hour_format == '24'){?> checked <?php } ?> value="24" >
                    <label><?php echo getFixedLabel('CLOCK24HOUR')?></label>
                    </li>
				</ul>
				<ul id="cal_shar" class="LdPop_ul2 LdPop_ul2Bor" style="margin:0px;padding-left:0px;">
					<li class="A"><img src="<?php echo lingdang_imageurl('cal_sharing.jpg', $theme) ?>" />
                    <span><?php echo getFixedLabel('SHAREDAGENDA')?></span>
                    </li>
					<li class="C"><?php echo getFixedLabel('SHARESCHEDULESELECTEDUSERS')?></li>
					<li class="C"><?php echo getFixedLabel('ADDSHARESCHEDULESELECTEDUSERS')?></li>
					<li class="C"><?php echo getFixedLabel('REMOVEINVITEUSER')?></li>
				</ul>
        		<ul class="LdPop_ul3" style="margin-top: 0px;">
                    <li class="L"><span><?php echo getFixedLabel('USERSCANCHOOSE')?></span>
					<select  ondblclick="addColumn('available_users','selected_users')" name="available_users" id="available_users" class=small size=5 multiple style="height:100px;width:100%">
						<?php
                            foreach($userDetails as $id=>$name)
							{
								if($id != '')
								echo "<option value=".$id.">".$name."</option>";
								}
						?>
					</select>
					</li>
					<li class="C">
                        <a class="Blue" onclick="incUser('available_users','selected_users')" title="<?php echo getFixedLabel('RIGHT') ?>">>></a>
                        <a class="Black" onclick="incUser('selected_users','available_users')" title="<?php echo getFixedLabel('LEFT') ?>"><<</a>
                    </li>
                    <li class="L"><span><?php echo getFixedLabel('USERHASSELECTED')?></span>
					<select ondblclick="addColumn('selected_users','available_users')" name="selected_users" id="selected_users" class=small size=5 multiple style="height:100px;width:100%">
						<?php
							foreach($shareduser_ids as $shar_id=>$share_user)
							{
									if($shar_id != '')
									echo "<option value=".$shar_id.">".$share_user."</option>";
							}
						?>
					</select>
					</li>
				</ul>
            </td>
          </tr>
        </table>
    </div>
    <div class="D_pbtn">
    	<input type="submit" class="D_pbtnok" name="save" value="<?php echo getFixedLabel('SAVE') ?>"  onclick = "userEventSharing('shar_userid','selected_users');"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="<?php echo getFixedLabel('CANCEL') ?>" onclick="fninvshnew('calSettings');"/>   
    </div>
</form>