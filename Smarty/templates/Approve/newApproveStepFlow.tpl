<link type="text/css" href="themes/softed/approveset.css" rel="stylesheet" />
<div class="approveflow-design" style="height: 100%;">
    <div class="E_pop_tit E_pop_tit_third">
        <strong class="E_ptita" style="color:#333333;" >{'LBL_APPROVE'|@getFixedLabel}</strong>
        <div class="flowstep" tag="firststep" style="background-color: #999;margin-left: 60px;">1</div>
        <span tag="firststep" style="float: left;line-height: 64px;margin: 0 10px;font-size: 16px;">{'CONFIGUREBASICINFO'|@getFixedLabel}</span>
        <div style="width: 60px; border-bottom: 0.6mm dashed #3B7CFF;float: left;margin: 32px 18px 0 10px;"></div>
        <div class="flowstep">2</div>
        <span style="float: left;line-height: 64px;margin: 0 10px;font-size: 16px;">{'CONFIGUREPROCESS'|@getFixedLabel}</span>
        <button class="E_ptitc" style="float:right;" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" id="imgclosenew" onclick="CrmPopup.getPopupObj('last').CancelEvent();" ></button>
        <input class="ld-button ld-button-primary marR20" style="float: right;margin-top: 16px;" type="button" value="{'SAVE'|@getFixedLabel}" name="btn_approvesave">
        <input class="ld-button" style="float: right;margin-top: 16px;margin-right: 12px;" type="button" value="{'ASTEP'|@getFixedLabel}" name="btn_prev">
    </div>
    <div class="zoom" style="right: 12%;">
        <div class="zoom-out" zoomtype="out" name="btn_zoom"></div>
        <span name="zoomvalue">100%</span>
        <div class="zoom-in" zoomtype="in" name="btn_zoom"></div>
    </div>
    <div class="approveflow-design-box" style="height: calc(100% - 64px);overflow: auto;width: 100%;">
        <div class="box-scale" name="nodelist" style="transform: scale(1); transform-origin: 50% 0px 0px;" >
            <!-- 单个节点 -->
        </div>
    </div>

    <!-- 点击+弹出菜单 -->
    <div style="position: absolute; top: 0px; left: 0px; width: 100%;display: none;" name="dv_menu">
        <div>
            <div class="ant-popover add-node-wrapper ant-popover-placement-rightBottom" style="left: 975px; top: 148px; transform-origin: -2px 0px;">
                <div class="ant-popover-content">
                    <div class="ant-popover-inner" role="tooltip">
                        <div class="ant-popover-inner-content">
                            <div class="add-node-popover">
                                <div class="add-node-popover-body">
                                    <a class="add-node-popover-item approver" name="btn_addapprover">
                                        <div class="item-wrapper">
                                            <span><img src="themes/icon/button/approveuser.png"></span>
                                        </div>
                                        <span>{'APPROVER'|@getFixedLabel}</span>
                                    </a>
                                    <a class="add-node-popover-item route" name="btn_addconditionbranch">
                                        <div class="item-wrapper">
                                            <span><img src="themes/icon/button/conditionalbranch.png"></span>
                                        </div>
                                        <span>{'ConditionBranch'|@getFixedLabel}</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>