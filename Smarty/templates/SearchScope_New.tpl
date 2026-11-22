<div id="showselectsearchscope_new">
    {if $MODULE == 'Home' || $MODULE == 'VisualAnalysis'}
        <select onchange="SmOwnerSearchScope(this)" id="HomeSmOwnerSearchScope" name="HomeSmOwnerSearchScope" style="display:none">
    {else}
        <select onchange="SmOwnerSearchScopeChange(this,'{$MODULE}','{$CATEGORY}')" id="SmOwnerSearchScope" name="SmOwnerSearchScope" style="display:none">
    {/if}
        {if is_array($Merge_SmOwner) && $Merge_SmOwner|@count neq 0 &&$MODULE neq 'InventoryAccount' && $MODULE neq 'InventoryQuery' && $MODULE neq 'BankAccountSet' &&$MODULE neq 'Reminds'}
            {foreach key=User_Key item=User_value from=$Merge_SmOwner}
                {foreach key=User_id item=User_name from=$User_value}
                    {foreach key=User_name_key item=User_name_value from=$User_name}
                        {if $User_id eq $SelectedOwner2}
                            {assign var=optText value=$User_name_key}
                            {* wym XUQIU1002054 未勾选显示离职，隐藏离职成员*}
                            <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  value="{$User_id}" selected="true">{$User_name_key}</option>
                        {else}
                            {* bug 0015295 zyh 20150603  *}
                            {if $MODULE eq 'BankAccountSet'}
                                {if $User_id == 'SmOwer_Search_ShareMe' || $User_id == 'SmOwer_Search_MeToShare'}

                                {else}
                                    <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  value="{$User_id}">{$User_name_key}</option>
                                {/if}
                            {else}
                                <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  value="{$User_id}">{$User_name_key}</option>
                            {/if}
                            {* {/if} *}
                        {/if}
                    {/foreach}
                    {if $User_id eq 'smowner_search_senior'}
                        {assign var="show" value=1}
                    {/if}
                {/foreach}
            {/foreach}
        {else}
            <option value="SmOwner_Search_All" selected="true">全部</option>
        {/if}
    </select>
    <div id="SmOwnerSearchScope_new" style="float: left;"></div>
    {if $MODULE == 'Home' || $MODULE == 'VisualAnalysis'}
        {if $show eq 1}
            <i class="ld-fonticon ld-fonticon-users font20 lineheight30 marL10" title="{'VIEWRANGE'|@getFixedLabel}" tag="icon" onclick="SmOwnerSearchScopeheight();"></i>
        {/if}
    {else}
        {if isset($showviewrange) && $showviewrange == true}
            <i class="ld-fonticon ld-fonticon-users font20 lineheight30 marL10" title="{'VIEWRANGE'|@getFixedLabel}" onclick="SmOwnerScopehightuser();"></i>
        {/if}
    {/if}

</div>
<script>
    {if isset($Merge_SmOwner_arr)}
    if(ld('#SmOwnerSearchScope_new').length > 0){
        var Merge_SmOwner = {$Merge_SmOwner_arr};
        var SelectedOwner2 = '{$SelectedOwner2}';
        var displayinactiv = '{$displayinactiv}';
        {if isset($inactiveuser_arr)}
        var inactiveuser = {$inactiveuser_arr};
        {else}
        var inactiveuser = [];
        {/if}
        var MeAndShareMe_index = -1;
        var haveShareOrMe = 'no';

        var SmOwner_option_arr = [];
        ld.each(Merge_SmOwner,function (index,userscopeinfo) {
            if(SelectedOwner2 == userscopeinfo['value']){
                userscopeinfo['selected'] = true;
            }else{
                userscopeinfo['selected'] = false;
            }

            if('{$MODULE}' == 'BankAccountSet' && (userscopeinfo['value'] == 'SmOwer_Search_ShareMe' || userscopeinfo['value'] == 'SmOwer_Search_MeToShare')){
                haveShareOrMe = 'yes';
            }else {
                if(displayinactiv == 'no' && inactiveuser.indexOf(userscopeinfo['value']) >=0 ){

                }else{
                    if (userscopeinfo['value'] == 'SmOwner_Search_MeAndShareMe'){
                        MeAndShareMe_index = index;
                        userscopeinfo['title'] = '{'Mine'|@getFixedLabel}'+','+'{'Sharedwithme'|@getFixedLabel}'
                    }else if(userscopeinfo['value'] == 'SmOwer_Search_ShareMe' || userscopeinfo['value'] == 'SmOwer_Search_MeToShare' || userscopeinfo['value'] == 'SmOwner_Search_Me'){
                        haveShareOrMe = 'yes';
                    }
                    SmOwner_option_arr.push(userscopeinfo);
                }
            }

        });
        // 没有共享相关的查看范围，不显示"我的"
        if (haveShareOrMe == 'no' && MeAndShareMe_index != -1){
            SmOwner_option_arr.splice(MeAndShareMe_index, 1);
        }

        AjaxJSPage('ld_Select','include/js/component/ld_Select.js');
        var Showselect_obj = ld_Select.showSelect(ld('#SmOwnerSearchScope_new').get(0), {
            list: SmOwner_option_arr,
            width: '180px',
            optionwidth: '180px',
            showtype: 'click',
            selecticonurl: 'themes/icon2024/searchscope.png',
            selecticonhoverurl: 'themes/icon2024/searchscope1.png',
            optionobjattr: ['value'],
            filterable: true,
            change: function (evt){
                if('{$MODULE}' == 'Home' || '{$MODULE}' == 'VisualAnalysis'){
                    ld('#HomeSmOwnerSearchScope').val(evt.NavBarItem.value);
                    SmOwnerSearchScope(ld('#HomeSmOwnerSearchScope').get(0));
                }else{
                    ld('#SmOwnerSearchScope').val(evt.NavBarItem.value);
                    SmOwnerSearchScopeChange(evt.target,'{$MODULE}','{$CATEGORY}');
                }

            }
        });
        var crmPopupobj = CrmPopup.getPopupObj('last');
        if(crmPopupobj != undefined){
            crmPopupobj.Showselect_obj = Showselect_obj;
        }
    }
    {/if}

</script>
