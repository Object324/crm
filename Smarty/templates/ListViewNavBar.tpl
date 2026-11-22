{*模块页签*}
{if $PUBLICACCOUNTSTATUS eq 'yes' && $PUBLIC_ACCOUNT_POOL_LABEL|@count neq 0 && $LINKMODULECUSTOM neq 'true'}
    <script type='text/javascript' src='{$JSURL}include/js/cls_poolinfo_set.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/cls_publicpool_set.js?v={$GLOBALMINVERSION}'></script>
    <div>
        <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;float: left;">
        </div>
        <div style="width: 150px;float: left;margin-top: 9px;padding-left: 10px;">
            <div id="publicpoolselect"></div>
        </div>
    </div>
{elseif $PUBLICLeadsSTATUS eq 'yes' && $PUBLIC_Leads_POOL_LABEL|@count neq 0 && $LINKMODULECUSTOM neq 'true'}
    <script type='text/javascript' src='{$JSURL}include/js/cls_poolinfo_set.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/cls_publicpool_set.js?v={$GLOBALMINVERSION}'></script>
    <div>
        <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;float: left;">
        </div>
        <div style="width: 150px;float: left;margin-top: 9px;padding-left: 10px;">
            <div id="publicpoolselect"></div>
        </div>
    </div>
{elseif $MODULE == 'Stock' || $MODULE == 'OutboundOrder' || $MODULE == 'InventoryAccount' || $MODULE == 'InventoryQuery'|| $MODULE == 'Checks'}
    <input type="hidden" id="wareid" name="wareid" value="{$WAREHOUSEID}" />
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;">
    </div>
{elseif $MODULE eq 'WorkSheet'}
    <input type="hidden" id="wareid" name="wareid" value="{$WAREHOUSEID}" />
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;">
    </div>
{elseif $MODULE eq 'CollectionSlip'}
    <input type="hidden" id="wareid" name="wareid" value="{$WAREHOUSEID}" />
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;">
    </div>
{elseif $MODULE eq 'BankCash'}
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;">
    </div>
{elseif $MODULE eq 'Calendar' && $LINKMODULECUSTOM neq 'true'}
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;border: none;">
    </div>
{elseif $MODULE eq 'SalesGoal'}
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;">
    </div>
{elseif $MODULE eq 'Reminds'}
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;">
    </div>
{elseif $MODULE eq 'WorkReportList' && $LINKMODULECUSTOM neq 'true'}
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;">
    </div>
{elseif $MODULE eq 'Approve'}
    {include file='Approve/ListView_Header.tpl'}
{elseif $MODULE eq 'Users' && $PRMUSERSTATUS == 'yes'}
    <div class="salestarget-tab" id="{$MODULE}_navbar_div" style="height: 50px;margin: 0;">
    </div>
{/if}

<script>
    var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    var listview_module = '{$MODULE}';
    var ListViewNavbarlist = [];
    var ListViewNavbarcur = 0;
    {if isset($ListViewNavbarcur)}
    ListViewNavbarcur = {$ListViewNavbarcur};
    {/if}
    {if isset($ListViewNavbarlist)}
    ListViewNavbarlist = {$ListViewNavbarlist};
    {/if}


    //公海下拉框下拉框
    {if isset($poollist)}
        if(ld('#publicpoolselect').length > 0){ldelim}
            var poollist = {$poollist};
            AjaxJSPage('ld_Select','include/js/component/ld_Select.js');
            //zkt 20240129 BUG20240123-52 cs1账号不是公海超级管理员，但可以编辑、维护公海。
            var tmpfieldoptions = [];
            {if $PUBLIC_ACCOUNT.administrator eq 'yes' || $PUBLIC_Leads.administrator eq 'yes' || $IS_ADMIN eq 'yes'}
                //公海列表增加操作操作按钮
                {literal}
                    for(let i = 0;i<poollist.length;i++){
                        poollist[i].operations = [];
                        var edithtml = '<a class="tip-items-list bindtip" href="javascript:void(0);" tag="edit" pool_id="'+poollist[i].pool_id+'" onclick="event.stopPropagation();cls_poolinfo_set.static_editpopup(\''+listview_module+'\',ld(this));" style="line-height: 1.1;" data-tip="" data-direction="top" data-type="position">' +
                            '<i class="ld-fonticon ld-fonticon-edit"></i>' +
                            '</a>';
                        poollist[i].operations.push({'label':edithtml});
                        if(poollist[i].pool_id > 1){
                            var delhtml = '<a class="tip-items-list" href="javascript:void(0);" tag="delete" pool_id="'+poollist[i].pool_id+'" onclick="event.stopPropagation();cls_poolinfo_set.static_delete(\''+listview_module+'\',ld(this))" style="margin-left:8px;line-height: 1.1;" data-tip="" data-direction="top" data-type="position">'+
                                '<i class="ld-fonticon ld-fonticon-del"></i>'+
                                '</a>';
                            poollist[i].operations.push({'label':delhtml});
                        }
                        var draghtml = '<a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;margin-left:8px;" data-tip="" data-direction="right" data-type="position"></a>';
                        poollist[i].operations.push({'label':draghtml});
                    }
                {/literal}
                tmpfieldoptions = [
                    /*{ldelim}
                        'iconurl': 'themes/icon2024/set.png',
                        'iconhoverurl': 'themes/icon2024/set-hover.png',
                        'label': '{'PUBLICCUSTOMERSET'|@getFixedLabel}',
                        'clickevent': function (evt){ldelim}
                            if(listview_module == 'Accounts'){ldelim}
                                var cls_publicAccounts = new publicAccounts(popupobj);
                                cls_publicAccounts.edit_account_public_pool(evt.target,evt.target);
                                {rdelim}
                            else if(listview_module == 'Leads'){ldelim}
                                var publicLeadslistobj;
                                AjaxJSPage('publicLeads.js','include/js/modules/Leads/publicLeads.js');
                                publicLeadslistobj = new publicLeads(popupobj);	//公海参数、公海池
                                publicLeadslistobj.edit_account_public_pool(evt.target,evt.target)
                                {rdelim}
                        {rdelim}
                    {rdelim},*/
                    {ldelim}
                        'label': '<i class="ld-fonticon ld-fonticon-add" style="font-size: 20px;margin-right: 2px;vertical-align: middle;color:var(--ld-font-link-color);"></i><span style="color:var(--ld-font-link-color);display: initial;">{'createpublicaccountpool'|@getFixedLabel}</span>',
                        'parameter': ' tag="create" pool_id="0" ',
                        'clickevent': function (evt){ldelim}
                            cls_poolinfo_set.static_editpopup(listview_module,evt.target)
                        {rdelim}
                    {rdelim}
                ];
                {if $IS_ADMIN eq 'yes'}
                    tmpfieldoptions.push(
                        {ldelim}
                            'label': '<i class="ld-fonticon ld-fonticon-set" style="font-size: 20px;margin-right: 2px;vertical-align: middle;"></i>{'Highseasparametersetting'|@getFixedLabel}',
                            'clickevent': function (evt){ldelim}
                                var publicpool_setobj = new cls_publicpool_set(listview_module);
                                publicpool_setobj.CreatePopup();
                            {rdelim}
                        {rdelim}
                    );
                {/if}
            {/if}


            {literal}
                //生成公海下拉框
                var homeapproveobj = ld_Select.showSelect(ld('#publicpoolselect').get(0), {
                    list: poollist,
                    optionwidth: '253px',
                    showtype: 'click',
                    selecticonurl: 'themes/icon2023/publicpoolnew.png',
                    optionobjattr: ['accounttype','pool_id'],
                    conheight: 360,
                    change: function (evt){
                        if(listview_module == 'Accounts'){
                            cls_PublicAccount.showCustomType(evt.target);
                        }
                        else if(listview_module == 'Leads'){
                            PublicLeadsObj.showCustomType(evt.target);
                        }
                    },
                    fixedoptions: tmpfieldoptions,
                    showselectafter: function () {
                        //公海池拖动排序
                        var dragobj = ld('#publicpoolselect').find('.ld_Select-option-content').get(0);
                        Sortable.create(dragobj, {
                            draggable:".ld_select-optionopli",
                            handle:".drag-handle",
                            onStart: function (evt){

                            },
                            onEnd: function (evt){
                                var liobjs = ld(evt.from).find('.ld_select-optionopli');
                                if(liobjs.length > 0){
                                    var pool_ids_str = '';
                                    liobjs.each(function (index,liobj) {
                                        pool_ids_str += ld(liobj).data('pool_id')+';';
                                    });
                                    var surl = 'index.php?module='+listview_module+'&action='+listview_module+'Ajax&file=createPublicAccountPool&sortpublicpool=yes';
                                    surl += '&pool_ids_str='+pool_ids_str;
                                    ldAjax(surl,'',function(data){
                                        if(data.code==1){
                                            DelProgressObjs();

                                        }
                                    })

                                }
                            }
                        });
                    }
                });
            {/literal}

        {rdelim}
    {/if}


    //页签
    var listviewnavbarobj = ld('#'+listview_module+'_navbar_div');
    if(listviewnavbarobj.length > 0){
        var listnavbardata = {
            NavBarSelKey : ListViewNavbarcur,
            ShowAllItemInfo: true,
            WidthFixed : false,
            CssVarList: {
                NavBarItemMinWidth: '120px'
            },
            NavBarMoreDefaultText: arrJsPopLabel['MORE'],
            MaxSimpleNum : 6,
            OnClick : function(evt){
                if(listview_module == 'Stock' || listview_module == 'OutboundOrder' || listview_module == 'InventoryAccount' || listview_module == 'InventoryQuery'|| listview_module == 'Checks'){
                    getWarehouse(evt.NavBarItem.id);
                }
                else if(listview_module == 'WorkSheet'){
                    getWorkSheetStatus(evt.NavBarItem.value);
                }
                else if(listview_module == 'CollectionSlip'){
                    getCollectionSlipStatus(evt.NavBarItem.value);
                }
                else if(listview_module == 'BankCash'){
                    getBankCash(evt.NavBarItem.id);
                }
                else if(listview_module == 'Calendar'){
                    CalendarTabClick(evt.NavBarItem.value,CrmPopup.getPopupObj('last'));
                }
                else if(listview_module == 'SalesGoal'){
                    SalesGoalTabClick(evt.NavBarItem.value);
                }
                else if(listview_module == 'Accounts'){
                    cls_PublicAccount.showCustomType(evt.target);
                }
                else if(listview_module == 'Leads'){
                    PublicLeadsObj.showCustomType(evt.target);
                }
                else if(listview_module == 'Reminds'){
                    ld('#rptContentLoading').show();
                    showDefaultCustomViews(evt.target,listview_module,'',evt.NavBarItem.value,'&remindscategoryid='+popupobj.remindscategoryid);
                }
                else if(listview_module == 'WorkReportList'){
                    getWorkReportLogType(evt.NavBarItem.value,evt.target);
                }
                else if(listview_module == 'Users'){
                    getuserlist(evt.NavBarItem.value);
                }
            },
        };
        if(listview_module == 'Stock' || listview_module == 'OutboundOrder' || listview_module == 'Checks' || listview_module == 'InventoryAccount' || listview_module == 'InventoryQuery' || listview_module == 'BankCash'){
            listnavbardata.MaxSimpleNum = 8;
        }

        AjaxJSPage('ld_NavBar','include/js/component/ld_NavBar.js');
        var navbarobj = ld_NavBar.ShowNavBar(listviewnavbarobj.get(0),ListViewNavbarlist,listnavbardata);
        if(!empty(popupobj)){
            popupobj.ListViewNavBarObj = navbarobj;
            popupobj.ListViewNavbarlist = ListViewNavbarlist;
        }
    }
</script>