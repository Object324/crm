<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<form action="index.php" method="post" id="TopicBlockAdd" name="TopicBlockAdd">
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <input type="hidden" name="topicid" value="{$Topicinfo.topicid}"/>
        <tr>
            <td align="right"><font color="red">*</font>图标</td>
            <td align="left">
                <div style="padding:5px;">
                    <input type="radio" id="defaultIcon" name="iconselect" value="defaultIcon" onclick="cardsettings_iconselectonclick(event)" checked=""/><span>选择默认图标</span>&nbsp;&nbsp;
                    <input type="radio" id="localIcon" name="iconselect" value="localIcon" onclick="cardsettings_iconselectonclick(event)"/><span>选择本地图标</span>
                    <div id="defaultIcondiv" name="defaultIcondiv" style="padding-top: 5px;">{*style="display: block;height: 25px;width: 200px;position: absolute;left:360px;top: 59px;"*}
                        <a href="javascript:;" class="uploadfile" style="display:inline;">选择默认图标
                            <input type="button" style="height: 25px;width: 105px;" name="defaultIconname" onclick="CardSettingsobj.getDefaultIcon()" id="defaultIconname" >
                        </a>
                        <span class="info" name="span_defaultIconname" style="padding-left:5px;"></span>
                    </div>
                    <div id="localIcondiv" name="localIcondiv" style="display:none;padding-top: 5px;" >
                        <a href="javascript:;" class="uploadfile" style="display:inline;">{'Select_file'|@getFixedLabel}
                            <input type="file" style="height: 25px;width: 80px;" name="blockimagename" accept="image/*" id="blockimagename" onchange="CardSettingsobj.validateFilename(this)">
                        </a>
                        <span class="info" name="span_blockimagename" style="padding-left:5px;"></span>
                    </div>
                    
                </div>
            </td>
        </tr>
        <tr>
            <td align="right">小标题</td>
            <td align="left">
                <input class="controlInput btn-radius-system " name="blockname"  value="" type="text" >
            </td>
        </tr>
        <tr>
            <td align="right">内容</td>
            <td align="left">
                <input class="controlInput btn-radius-system " name="blockcontent"  value="" type="text" >
            </td>
        </tr>
    </table>
</form>