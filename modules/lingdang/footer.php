<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the 
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header$
 * Description:  Contains a variety of utility functions used to display UI 
 * components such as form headers and footers.  Intended to be modified on a per 
 * theme basis.
 ********************************************************************************/

global $app_strings;
if($current_user->id!=NULL
        &&($currentModule!='Home'&&$currentModule!='OftenUseReport'&&$currentModule!='Settings')) {
			echo "<script type='text/javascript'>
                if(typeof(ActivityReminderCallback) != ".
				"'undefined') ";
			$cur_time = time();
			$reminder_interval_reset = 2000*60*1;
			if($reminder_interval_reset > 0){
			 //32471: 单据序列表界面：界面后，不需要每隔几分钟刷新一下页面触发提醒，只需要刚进入序列表界面时刷新
               echo "ActivityReminderCallback();";
			/*	echo "window.setTimeout(function(){
						ActivityReminderCallback();
					},$reminder_interval_reset);";
            */
            
              //  echo  " myIntervalForSendNews();";

                //echo  'setInterval("myIntervalForSendNews()",2000*60*1)';
                
			} 
             // echo "AutoRemindCallBack()";
          //  echo "generateautoReminds();";
			echo "</script>";
}
$tmps= setGLobalURLSmarty($smarty);


if(file_exists('include/utils/globalStatic.php')&&file_exists(globalStatic::$root_directory.'include/js/modules/'.$module.'/'.$module.'Special.js'))
{
   
  
    
?>
<script type="text/javascript" src="<?php echo $tmps['jsurl'].'include/js/modules/'.$module.'/'.$module.'Special.js'?>"></script>
<?php }?>
</body>
</html>