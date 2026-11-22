	<div class="DivL_ServiceCharge" id="setGroup">
            <h2>{'ServiceCharge'|@getTranstab}</h2>
            <div class="ServiceCharge_title">
                <div class="group_bz">{'Grouping'|@getFixedLabel}</div>
                {if $ISADMIN eq 'yes'}
                <div class="creategroup_bz">
                    <a class="Xl_a" id="ServiceCharge_group" onclick="return false;" onmouseout="fnHideDrop('selectServiceCharge_group');" onmouseover="ViewfnDropDown(this,'selectServiceCharge_group');" href="javascript:void(0);">
                        {'CREATEGROUPS'|@getFixedLabel}<span class="icon-bluetriangle"></span>
                    </a>  
                    <ul onmouseover="fnShowDrop('selectServiceCharge_group')" onmouseout="fnHideDrop('selectServiceCharge_group')"  id="selectServiceCharge_group" style="display:none;z-index:999;">                                           
                        <li id="ServiceCharge_group1">
                            <a href="javascript:void(0);" onclick="setServiceChargeGroup('{$MODULE}','Add')">{'CREATEGROUPS'|@getFixedLabel}</a>
                        </li>
                        {if $ISGROUPEDIT eq 'yes'}
                            <li id="ServiceCharge_group2">
                                <a href="javascript:void(0);" onclick="setServiceChargeGroup('{$MODULE}','Edit')">{'EDIT'|@getFixedLabel}</a>
                            </li>
                            <li id="ServiceCharge_group3">
                                <a href="javascript:void(0);" onclick="setServiceChargeGroup('{$MODULE}','Del')">{'DELETE'|@getFixedLabel}</a>
                            </li>
                        {/if}
                        <li id="ServiceCharge_group4">
                            <a href="javascript:void(0);" onclick="setServiceChargeGroup('{$MODULE}','Soft')">{'SORT'|@getFixedLabel}</a>
                        </li>
                    </ul>
                </div>
                {/if}
                <input type="hidden" id="hiddengroupid" name="hiddengroupid" value="{$SELECTGROUPID}" />
            </div>
            <div id="refreshgroup" style="overflow-x: hidden;overflow-y: auto;height: 363px;width:100%;">
                <ul class="ServiceChargeul">
                {foreach key=groupid item=groupname name=group from=$GROUPALL}
                    {assign var=servicegroupid value=$groupname.servicegroupid}
                    {assign var=is_edit value=$groupname.is_edit}
                    <li><a href="#" {if $SELECTGROUPID eq $servicegroupid} class="On"{/if} id="change_table_here{$groupid}" onclick="change_table({$servicegroupid},{$is_edit},{$groupid},{$GROUPCOUNT},{$VIEWID});" >
                        {$groupname.servicegroupname} ({$groupname.groupcount})
                        </a>
                    </li>
                {/foreach}
                </ul>
            </div>
                            
        </div>