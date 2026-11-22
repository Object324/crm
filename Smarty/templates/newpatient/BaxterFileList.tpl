{*//ls 20230301  XUQIU1001143【百特】不良事件报告模块生成pdf和xml文件*}
<div class="DivCName DivCNamehover" onclick="showHideStatus('filelisttable','filelisttitle');">
    <span class="On" name="filelisttitle"></span>文件
</div>

<div class="DivC" name="filelisttable">
    <div name="file_operation_log_detail">
        <div style="width:100%; overflow: auto; min-height: 100px; max-height:460px;">
            <div style="height:100%;width:100%;">
                <table border=0 cellspacing=1 cellpadding="0" width="100%" class="listEntries">
                    <tr>
                        <th width="10%">操作</th>
                        <th width="10%">类型</th>
                        <th width="50%">标题</th>
                        <th width="20%">上次修改时间</th>
                        <th width="10%">创建人</th>
                    </tr>
                    {if !empty($BaxterFileList)}
                        {foreach key=index item=log from=$BaxterFileList}
                            <tr class="lvtColData">
                                <td align="center">
                                    <a class="Anu3_a" href="javascript:void(0);" onclick="baxterCreatePdfAndXml.getInstance().aws_download(this,'{$log.fileid}');">查看</a>
                                    <a class="Anu3_a" href="javascript:void(0);" onclick="baxterCreatePdfAndXml.getInstance().aws_delete(this,'{$log.fileid}');">删除</a>
                                </td>
                                <td align="left">{$log.file_type}</td>
                                <td align="left">{$log.title}</td>
                                <td align="left">{$log.created_at}</td>
                                <td align="left">{$log.creator}</td>
                            </tr>
                        {/foreach}
                    {else}
                        <tr style="height: 25px;" bgcolor="white">
                            <td colspan="5" align='center'><i>{'NONE'|@getFixedLabel}</i></td>
                        </tr>
                    {/if}

                </table>
            </div>
        </div>
    </div>

</div>


{*
<div class="DivCName DivCNamehover" onclick="showHideStatus('filelogtable','filelog');">
    <span class="On" name="filelog"></span>文件

</div>
<div class="PageDiv0" style="padding:3px 5px;margin-top:0px; ">
    <div class="ld-flex-start">
        <div class="ld-pagenum-div">{$recordListRange}</div>
        {$NAVIGATION}
    </div>
</div>
*}
{*<div class="Top">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td style="height: 42px;"></td>
            <td class="DivCR" valign="middle" >
                <div class="PageDiv0"  style="margin-top: 4px;margin-bottom:4px;">
                    <div class="ld-flex-start">
                        <div class="ld-pagenum-div">{$RELATEDLISTDATA.navigation.0}</div>
                        {$RELATEDLISTDATA.navigation.1}
                    </div>
                </div>
            </td>
        </tr>
    </table>
</div>*}{*


<div id="divRelated_yy" style="width: 100%; overflow: auto;" name="filelogtable">


<table border=0 cellspacing=1 cellpadding=3 width=100% style="background-color:#eaeaea;" class="*}
{*small*}{*
 listEntries">
    <tr style="height:25px" bgcolor=white>
        {if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
        && $RELATEDLISTDATA.entries|@count > 0}
            <td class="lvtCol commonCol">
                <input name ="{$RELATED_MODULE}_selectall" id="{$MODULE}_{$RELATED_MODULE}_selectCurrentPageRec" onclick="rel_toggleSelect(this.checked,'{$MODULE}_{$RELATED_MODULE}_selected_id','{$RELATED_MODULE}');"  type="checkbox">
            </td>
        {/if}
        {foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header}
            <td>{$_HEADER_FIELD}</td>
        {/foreach}
    </tr>
    {foreach key=_RECORD_ID item=_RECORD from=$RELATEDLISTDATA.entries}
        <tr bgcolor=white>
            {if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')}
                <td><input name="{$MODULE}_{$RELATED_MODULE}_selected_id" id="{$_RECORD_ID}" value="{$_RECORD_ID}" onclick="rel_check_object(this,'{$RELATED_MODULE}');" type="checkbox"  {$RELATEDLISTDATA.checked.$_RECORD_ID}></td>
            {/if}
            {foreach key=index item=_RECORD_DATA from=$_RECORD}
                *}
{* vtlib customization: Trigger events on listview cell onmouseover="vtlib_listview.trigger('cell.onmouseover', $(this))" onmouseout="vtlib_listview.trigger('cell.onmouseout', $(this))"*}{*

                {if $_RECORD_DATA|count_characters:true gt 800}
                    <td width="40%">{$_RECORD_DATA}</td>
                {else}
                    <td >{$_RECORD_DATA}</td>
                {/if}
                *}
{* END *}{*

            {/foreach}
        </tr>
        {foreachelse}
        <tr style="height: 25px;" bgcolor="white"><td><i>{'NONE'|@getFixedLabel}</i></td></tr>
    {/foreach}
</table>
</div>*}
