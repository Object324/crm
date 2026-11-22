{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<body>
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Customreport/Customreport.js"></script>
<!--中间-->
<div class="main_grid lfloat" style="width: 100%;">
    {if $ISADMIN eq 'on'}
      <div class="main_grid_top">
          <div class="grid-view-title overflow-hidden">
          </div>
          <div class="grid_tool">
            <div class="create-entity-toolbar lfloat prelative">
              <a id="report-add-folder" title="{'ADDFOLDER'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat">
                <span>{'ADDFOLDER'|@getFixedLabel}</span>
              </a>
              <a id="report-sort-folder" title="{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat">
                <span>{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}</span>
              </a>
              <a id="report-show-folder" title="{'SHOWHIDDENFOLDER'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat">
                <span>{'SHOWHIDDENFOLDER'|@getFixedLabel}</span>
              </a>
            </div>
          </div>
      </div>
    {/if}
    <div class="main_grid_box">
        <div class="grid-analysis-box">
          <div class="grid-analysis-header">
          </div>
          <div class="cont_wrap clear_float" id="report-list">
            {include file="modules/Customreport/CustomreportContents.tpl"}
          </div>
        </div>
    </div>
</div>
<!--中间 end-->

<!--添加文件夹-->
<div id="folder_text" class="E_pop_box LdPopWidth400px" style="display:none;">
    <div class="E_pop_tit">
    	<strong class="E_ptita">{'ADDFOLDER'|@getFixedLabel}</strong>
      <button id="report-href-folder" class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></button>
    </div>
    <div class="pad2010 ctextalign">
      <span class="padR10">{'Folder_name'|@getFixedLabel}</span>
      <input id="folder_name" name="folderName" type="text" class="detailedViewTextBox gwidth50" onfocus="this.className='commonDetailedTextBox gwidth50 bgcolordh'" onblur="this.className='detailedViewTextBox gwidth50'">
      <span class="padL10">{'50word_limit'|@getFixedLabel}</span>
    </div>
    <div class="E_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" id="report-save-folder" /><span>&nbsp;</span>
      <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id="report-hide-folder"/> 
    </div>
</div>
<!--文件夹排序-->
<div id="folder_sortview" class="E_pop_box LdPopWidth600px" style="display:none;">
<div id="folder_sortview_content_div"></div>
</div>
<!--建立报表-->
<div id="createreport_div" class="E_pop_box LdPopWidth600px" style="display:none;">
<div id="createreport_content_div"></div>
</div>
<!--编辑报表-->
<div id="editreport_div" class="E_pop_box LdPopWidth500px" style="display:none;">
<div id="editreport_content_div"></div>
</div>
<!--分配-->
<div id="allocatereport_div" class="E_pop_box LdPopWidth500px" style="display:none;">
<div id="allocatereport_content_div"></div>
</div>
<!--显示隐藏报表-->
<div id="show_report" class="E_pop_box LdPopWidth600px" style="display:none;">
<div id="show_report_content_div"></div>
</div>

<!--显示隐藏文件夹-->
<div id="show_folder" class="E_pop_box LdPopWidth600px" style="display:none;">
<div id="show_foldert_content_div"></div>
</div>

<script language="javascript" type="text/javascript">
  //高度
  ld('.main_grid .main_grid_box').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top)+'px');
</script>