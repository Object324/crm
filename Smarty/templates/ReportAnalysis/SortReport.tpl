<!--文件夹排序-->
<div id="folder_sortview_content_div">
    <table class="ld-pop-container-second padT2" width="100%" align="center" cellspacing="0" cellpadding="2" border="0">
        <tr>
            <td>
                <select  id="select_folder" multiple="" style="border:0px #ddd solid;width: 190px; height: 200px;padding-top: 3px;" onchange="selectedColumnClick(this);" name="select_folder" size="10" >
                    {foreach item=f key=k from=$list}
                        <option value="{$f.report_id}_{$f.modulename}">{$f.report_name}</option>
                    {/foreach}
                </select>
            </td>
            <td  align='center'>
                <a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFIxedLabel}" onclick="select_moveUp('select_folder')"></a>
                <a class="icon-newhomearr icon-mdown" href="javascript:;" style="margin-top: 15px;" title="{'MOVEDOWN'|@getFIxedLabel}" onclick="select_moveDown('select_folder')"></a>
            </td>
        </tr>
    </table>
</div>
