/**
 * 弹窗对象
 * @typedef {object} PopupObj
 */
/**
 * 请求返回值数据
 * @typedef {object} responseData
 */
/**
 * 简报、龙虎榜、年度分析仪表盘列表等组件的编辑事件
 * @param Option 参数列表对象
 * @param {function(PopupObj,responseData)} callBack 请求回调方法
 */
function EditHomeStuffDetail(Option,callBack) {
    var surl = Option.surl,
        params_data = Option.params_data,
        tmpwidth = ld(window).width(),
        crmPopupobj=CrmPopup.load("","","",tmpwidth,'Home',"","","","");
    var popuptype = Option.popuptype ? Option.popuptype : '';
    crmPopupobj.createHeadHtml = function (){
        this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
        this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
        this.popupheadhtml +='<div class="E_pop_tit_Second_Right" style="float: right;">';
        this.popupheadhtml += '<div class="ld-button ld-button-primary" name="save" id="save" >'+arrJsPopLabel['SAVE']+'</div>';
        this.popupheadhtml += '<div class="E_ptitc" value="' + arrJsPopLabel['LBL_CLOSE'] + '" title="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose"></div>';
        this.popupheadhtml += '</div>';
        this.popupheadhtml += '</div>';
    }
    if (popuptype != 'WorkBriefReport'){
        //wyt 0613 BUG0068114 销售简报设置：建议参考数据看板模块，在未保存关闭时弹出提醒框
        crmPopupobj.canceledit = crmPopupobj.CancelEvent;
        crmPopupobj.CancelEvent = function(){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", Option.delete_str);
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                crmPopupobj.canceledit();
            })
        }
    }
    ldAjax(surl, params_data, function (data){
        if(data.code === 1){
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth1600px",'Home',"","","","","");
            crmPopupobj.show(data.result.content);
            CrmPopup.fullScreen(ld("#" + crmPopupobj.divid), crmPopupobj);
            crmPopupobj.center();
            callBack(crmPopupobj,data);
        }
        DelProgressObjs();
    })
}