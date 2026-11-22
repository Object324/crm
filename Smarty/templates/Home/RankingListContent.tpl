<style>
    .ranking-list-content{
        height:280px;overflow-y: scroll;
    }
    .ranking-list-content .table-header{
        padding: 10px 7px;border-bottom: 1px solid #ebebeb;
    }
</style>
<div class="ranking-list-content">
    <table width="100%" cellspacing="0" cellpadding="0">
        <thead>
        <tr>
            {foreach item=head from=$HOME_STUFF['Details']['thead']}
            <td class="table-header">{$head}</td>
            {/foreach}
        </tr>
        </thead>
        <tbody>
        {foreach item=row from=$HOME_STUFF['Details']['list']}
        <tr class="lvtColData">
            <td class="table-header">{$row['sort']}</td>
            <td class="table-header">{$row['branch_office']}</td>
            <td class="table-header">{$row['money']}</td>
        </tr>
        {/foreach}
        </tbody>
    </table>
</div>