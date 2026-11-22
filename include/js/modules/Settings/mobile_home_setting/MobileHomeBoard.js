homeboardlistdrag('MobileReport');
function MobileHomeboard() {
    var that = this;
    //this.module = 'Settings';
    var popupobj = CrmPopup.getPopupObj("last");
    popupobj.recode = ld('#' + popupobj.divid + ' #boardid').val();
    this.module = popupobj.boardtype=='MobileReport'?'Settings':popupobj.boardtype;
    that.setEvent = function(){

    }


}


function editMobileHomeboard(boardid,boardtype){
    if(boardid==-100){
        //移动端看板默认看板
        editDefaultMobileHomeBoard();
        return;
    }
    ld('#homeboard_List').hide();
    var surl='index.php?module=Settings&action=SettingsAjax&file=CreateMobileHomeBoard&from_module='+boardtype+'&boardid='+boardid;
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth1600px",'Settings',"","","","");
   //zsk 2024/3/12 XUQIU1002414 看板交互优化
    var styleStr1 = (boardid==0) ? '#3B7CFF' : '#999';
    var styleStr2 =(boardid==0)?'#999':'#3B7CFF';
    crmPopupobj.createHeadHtml = function (){
        this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
        this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
        this.popupheadhtml += '<div style="margin: auto;background-color: #fff;margin-left: 60px;float: left;">\n' +
            '                <label name="step1"><div class="ld_homeboard_head_step" style="background:'+styleStr1+'">1</div>\n' +
            '                <span style="float: left;margin: 21px 10px;font-size: 16px;">'+arrJsPopLabel['FILLBASICINFORMATION']+'</span></label>\n' +
            '                <div style="width: 60px; border-bottom: 0.6mm dashed #3B7CFF;float: left;margin: 32px 18px 0 10px;"></div>\n' +
            '                <label name="step2"><div class="ld_homeboard_head_step" style="background-color:'+styleStr2+'">2</div>\n' +
            '                <span style="float: left;margin: 21px 10px;font-size: 16px;">'+arrJsPopLabel['SETLAYOUTRULES']+'<span style="font-size: 12px;">('+arrJsPopLabel['MobileCankao']+')</span></span></label>\n' +
            '            </div>';
        this.popupheadhtml +='<div class="E_pop_tit_Second_Right" style="float: right;">';
        this.popupheadhtml += '<div class="ld-button marR20" name="next" id="next">'+arrJsPopLabel['NEXT']+'</div>';
        this.popupheadhtml += '<div class="ld-button" name="astep" id="astep" style="display: none;">'+arrJsPopLabel['ASTEP']+'</div>';
        this.popupheadhtml += '<div class="ld-button ld-button-primary marR20" name="save" id="save" style="display: none;">'+arrJsPopLabel['SAVE']+'</div>';
        this.popupheadhtml += '<div class="E_ptitc" value="' + arrJsPopLabel['LBL_CLOSE'] + '" title="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose"></div>';
        this.popupheadhtml += '</div>';
        this.popupheadhtml += '</div>';
    }
    crmPopupobj.cancelhomeboard = crmPopupobj.CancelEvent;
    crmPopupobj.CancelEvent = function (){
        var delete_str = arrJsPopLabel['CANCELHOMEBOARDCHECK'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",delete_str);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            crmPopupobj.cancelhomeboard();
        })
    }

    ldAjax(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth1600px",'Settings',"","","","","");
            crmPopupobj.show(data.result.content);

            var crmPopupJqObj = ld('#'+ crmPopupobj.divid);
            tooltip(crmPopupJqObj.find('.tip-items-list'),{transition: true, time: 200});
            crmPopupJqObj.css('width','100%');
            crmPopupJqObj.css('height','100%');
            crmPopupobj.center();
            crmPopupobj.boardtype = boardtype;

            crmPopupobj.DatarangeSetListDefault = data.result.DatarangeSetListDefault;
            crmPopupobj.DatarangeSetList = {};

            crmPopupobj.StuffOtherSet = data.result.StuffOtherSet;
            crmPopupobj.StuffOtherSetList = {};

            if(!empty(data.result.DatarangeSetList)){
                crmPopupobj.DatarangeSetList = data.result.DatarangeSetList;
            }
            if(boardid > 0){
                crmPopupobj.Homeboard_content = data.result.Homeboard_content;
                crmPopupobj.chosedatastyle = data.result.Homeboard_content.timesearchdefault;
            }else{
                crmPopupobj.chosedatastyle = 'thismonth';
            }
            crmPopupobj.from_module = "MobileReport";
            crmPopupobj.data_select = data.result.data_select;
            if(ld('#edithomefromlist').val() == 'yes'){
                crmPopupobj.edithomefromlist = 'yes';
            }else {
                crmPopupobj.edithomefromlist = 'no';
            }
            MobileHomeboard.prototype = Homeboard.getInstance();
            MobileHomeboard.prototype.constructor = MobileHomeboard;
            var cls_homeboardobj = new MobileHomeboard();
            crmPopupobj.homeboardobj = cls_homeboardobj;
            //zsk 2024/3/12 XUQIU1002414 看板交互优化
            if(boardid>0){
                crmPopupobj.homeboardobj.nextBtnClick();
            }
            //zxm 20231021 常用模块组件永远在最上面  时间筛选器在常用模块后面
            if(crmPopupJqObj.find('#stuff_108').length>0) {
                crmPopupJqObj.find('[name=homeboard_draw_layout_block]').prepend(crmPopupJqObj.find('#stuff_108'));
                crmPopupJqObj.find('#stuff_108').after(crmPopupJqObj.find('.home_header_top'));
            }
        }
    })
}
//编辑移动端旧工作台
function editDefaultMobileHomeBoard(){
    var surl='index.php?module=Settings&action=mobile_home_setting&parenttab=Settings';
    surl+="&ReportHeader=dheader";
    var crmPopupobj=CrmPopup.load("","","","900",'Settings',"","","","");
    ldAjaxNoProgress(surl,'',function(data){
        if (data.code == 1) {
            crmPopupobj.setParams(data.result.title, "", "", "900", 'Settings', "", "", "", "", "");
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
            crmPopupobj.center();
        }
    });
}
