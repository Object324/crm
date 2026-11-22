<div tag="tableset" style="display: flex;justify-content: space-between">
    <div id="width_left" style="vertical-align:top;width:10%;min-width: 300px;background-color: #F8F8F8">
        {*字段选择*}
        <div class="pad10" style="float: left;">
            <div class="ld_saleskitlist_block">
                <div class="ld_saleskitlist_search">
                    <input type="text" tag="searchFields" class="ld-input-inner ld-input-inner-add" id="" placeholder="{'Looking'|@getFixedLabel}" autocomplete="off" style="color: rgb(153, 153, 153);">
                    <b class="ld-icon-search"></b>
                </div>
            </div>
            <div id="fieldListDiv" class="selectPop" style="overflow: auto;float: left;width: 100%;">
                <div style="width:100%;">
                    <ul class="filetree" id="fieldList">
                        {'LOADING'|@getFixedLabel}
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <div style="vertical-align: top;width:90%;max-width:calc(100% - 300px);">
        <div class="report-detail">
            <div class="report-tips" style="border-bottom: 1px solid #eee;">
                <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
                    <tr>
                        <td width="50%" align="left">
                            <div class="report-tips">
                                <a title="{'NewFormula'|@getFixedLabel}" class="ld-button ld-button-primary" id="creat_new_formula">
                                    <span>{'NewFormula'|@getFixedLabel} </span>
                                </a>
                                <a title="{'Reportsortingmethod'|@getFixedLabel}" class="ld-button ld-button-primary" id="reportsortingmethod">
                                    <span>{'Reportsortingmethod'|@getFixedLabel} </span>
                                </a>
                            </div>
                        </td>
                        <td width="50%" align="left">
                            <span style="float:left;line-height: 18px;">{'Showdetails'|@getFixedLabel}&nbsp;&nbsp;</span>
                            <input class="second_switch" type="checkbox" id="show_detail" name="show_detail" {if !$report_info || $report_info['show_detail']=='yes'}checked{/if}>
                            <input type="hidden" name="report_id" id="report_id" value="{$report_info['report_id']}">
                            <input type="hidden" name="report_type" id="report_type" value="{$report_info['report_type']}">
                            {*编辑的时候用来传值的*}
                            <input type="hidden" name="selectedModules" id="selectedModules" value="{$report_info['selectedModules']}">
                        </td>
                    </tr>
                </table>
            </div>
            <div class="report-tips">
                <div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon" style="background-size: 20px;width:20px;height:20px;margin:10px 4px 10px 0 ;background-position:0 -300px;"></div>{'SaveSee'|@getFixedLabel}
            </div>
            <!--分页-->
            <div style="display:block;height:38px;margin: 10px 0;">
                <div class="PageDiv0">
                    <ul>
                        <li name='totaldescription'>{$RECORDLISTRANGMSG}</li>
                        <li><span id="goleft" class="no-icon-prevpage"></span></li>{*左边箭头*}
                        <li class="Input" id="pageoftotalpages">1/1</li>
                        <li><span id="goright" class="no-icon-nextpage"></span></li>
                        <li>{'GoTo'|@getFixedLabel}<input class="txtBox btn-radius-system pagenum_system search_bg marLR5" value="1" id="changePageCount" name='pagenum' type="text"/>{'PAGE'|@getFixedLabel}</li>
                        <li >
                            <select class="detailedViewTextBox" name="limitrecord" id="limitrecord">
                                <option value="20">20 {'ItemPage'|@getFixedLabel}</option>
                                <option value="50">50 {'ItemPage'|@getFixedLabel}</option>
                                <option value="100">100 {'ItemPage'|@getFixedLabel}</option>
                                <option value="200">200 {'ItemPage'|@getFixedLabel}</option>
                                <option value="500">500 {'ItemPage'|@getFixedLabel}</option>
                                <option value="1000">1000 {'ItemPage'|@getFixedLabel}</option>
                                <option value="2000">2000 {'ItemPage'|@getFixedLabel}</option>
                            </select>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="report-detail" style="overflow-y: hidden;">
                {include file="CustomTables/detailtable.tpl"}
            </div>
        </div>
    </div>
</div>






