
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="CardSettings"/>
    <input type="hidden" name="action"/>
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            公司简介设置
        </span>
        </div>
        <div class="grid_tool">
            <div class="create-entity-toolbar lfloat prelative">
                <a href="javascript:;" class="pg-btn-blue dinline-block lfloat" onclick="CardSettingsobj.CompanyProfileEdit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
            </div>
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float">
                <div class="TitleHeading">
                    公司简介
                </div>
                <table name="companyprofiletable" class="singleList" width="100%" border="0" cellspacing="0" cellpadding="5"
                       style="color:#555;">
                    <tr>
                        <td width="20%" class="cellLabel"> 标题 </td>
                        <td width="80%" class="borderBR">{$OrganizationInfo.brief_title}</td>
                    </tr>
                    <tr>
                        <td width="20%" class="cellLabel"> 简介 </td>
                        <td width="80%" class="borderBR">
                            <div style="padding: 5px;">
                                {$OrganizationInfo.brief|@html_entity_decode}
                            </div>
                        </td>
                    </tr>
                    <tr style="height:85px">
                        <td width="20%" class="cellLabel"> {'PICTURE'|@getFixedLabel} </td>
                        <td width="80%" class="borderBR">
                            {if $OrganizationInfo.image_main eq ''}
                                
                            {else}
                                <div name="image_main"  style="width:200px;">
                                    <a style=" border:0px solid #000; " href="{$IMAGE_PATH}{$OrganizationInfo.image_main}" target="_blank">
                                        <img style="width:100px; height:80px;" src="{$IMAGE_PATH}{$OrganizationInfo.image_main}" title="{$OrganizationInfo.image_main}" border="0">
                                    </a>
                                </div>
                            {/if}
                        </td>
                    </tr>
                    <tr>
                        <td width="20%" class="cellLabel"> {'VIDEOLINK'|@getFixedLabel} </td>
                        <td width="80%" class="borderBR">
                            {$OrganizationInfo.video_link}
                        </td>
                    </tr>
                    <tr style="height:85px">
                        <td width="20%" class="cellLabel"> {'VIDEOCOVER'|@getFixedLabel} </td>
                        <td width="80%" class="borderBR">
                            {if $OrganizationInfo.video_cover eq ''}
                                
                            {else}
                                <div name="video_cover"  style="width:200px;">
                                    <a style=" border:0px solid #000; width:100px;" href="{$IMAGE_PATH}{$OrganizationInfo.video_cover}" target="_blank">
                                        <img style="width:100px; height:80px;" src="{$IMAGE_PATH}{$OrganizationInfo.video_cover}" title="{$OrganizationInfo.video_cover}" border="0">
                                    </a>
                                </div>
                            {/if}
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</form>