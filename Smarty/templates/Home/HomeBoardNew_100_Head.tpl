<tr id="headerrow_{$stuffinfo['stuffid']}" >
    <th class="ld-stuff-tit">
        <div class="ld-stuff-tit-name tip-items-list" style="float: left;"
             data-tip="{$stuffinfo['StuffLabel']}" data-direction="top" data-type="position">
            {$stuffinfo['StuffLabel']}
        </div>
        {*待审批现在不要设置按钮 后面可能需要再加吧*}
        {if $IS_ADMIN eq 'yes' && $stuffinfo['stuffid']!=39 }
            <i class="ld-fonticon ld-fonticon-set lineheight24" onclick="{$SetClick}"></i>
        {/if}
    </th>
    <th>
        {if $stuffinfo['stuff_url']['url'] && $stuffinfo['stuff_url']['url'] != ''}
            <a style="height: 25px; margin-right: 20px;float: right; font-size:12px; color:#999;font-weight: normal;" title="{'MORE'|@getFixedLabel}" onclick="homestuffObj.home_href_popup('{$stuffinfo['stuffid']}','{$stuffinfo['boardstuffid']}','','index.php?pageto_module=Approve&pageto_action=ApproveListViewCount','')" href="javascript:;" id="a_{$stuffinfo['stuffid']}">
                {'MORE'|@getFixedLabel}<b class="home_next"></b>
            </a>
        {/if}
    </th>
</tr>