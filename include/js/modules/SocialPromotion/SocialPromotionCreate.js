ld(function () {
    var  popupobj = CrmPopup.getPopupObj("last");
    ld('#'+popupobj.divid).find(' #step2').hide();
    ld('#'+popupobj.divid).find(' #step3').hide();
    //默认隐藏三个字段
    var activitytype = ld('#'+popupobj.divid+' [name =cmb_span_optiontext_social_activitytype]').val();
    if(activitytype == activitytypeArr.onlyForm || mode =='edit'){
        ld('#'+popupobj.divid).find(' [name=h5pageurl]').parent().parent().hide();
        ld('#'+popupobj.divid).find(' [name=h5pagebutton]').parent().parent().hide();
        ld('#'+popupobj.divid).find(' [name=h5buttoncolor]').parent().parent().hide();
        ld('#'+popupobj.divid).find(' #ACTIVITYH5PAGEHELP').hide();
    }else{
        ld('#'+popupobj.divid).find(' #ACTIVITYH5PAGEHELP').show();
    }

    // 第一步隐藏上一步step按钮
    ld('#'+popupobj.divid+'_btnBack').unbind('click').bind('click',function () {
        socialCreateBackStep();
    }).hide();
    // ld('#'+popupobj.divid+'_btnBack').hide();


    // 隐藏单据编号
    ld('#'+popupobj.divid).find(' [name=socialpromotion_no]').parent().parent().hide();

    // h5urlpage添加*
    ld('#'+popupobj.divid).find(' #step1 tr').eq(8).find('font').html('*');

    //监听活动类型改变
    /*ld('#'+popupobj.divid+' [name =cmb_span_optiontext_social_activitytype]').on('DOMNodeInserted',function(){
        var activitytype = ld('#'+popupobj.divid+' [name =cmb_span_optiontext_social_activitytype]').val();
        if(activitytype == activitytypeArr.onlyForm ){
            ld('#'+popupobj.divid+ ' [name=h5pageurl]').parent().parent().hide();
            ld('#'+popupobj.divid+ ' [name=h5pagebutton]').parent().parent().hide();
            ld('#'+popupobj.divid+ ' [name=h5buttoncolor]').parent().parent().hide();
            ld('#'+popupobj.divid+ ' #ACTIVITYH5PAGEHELP').hide();
            ld('#'+popupobj.divid+ ' #ACTIVITYDESCH5ANDFORM').hide();
            ld('#'+popupobj.divid+ ' #ACTIVITYDESCFORM').show();
            popupobj.center();
        }else{
            ld('#'+popupobj.divid+ ' [name=h5pageurl]').parent().parent().show();
            ld('#'+popupobj.divid+ ' [name=h5pagebutton]').parent().parent().show();
            ld('#'+popupobj.divid+ ' [name=h5buttoncolor]').parent().parent().show();
            ld('#'+popupobj.divid+ ' #ACTIVITYH5PAGEHELP').show();
            ld('#'+popupobj.divid+ ' #ACTIVITYDESCH5ANDFORM').show();
            ld('#'+popupobj.divid+ ' #ACTIVITYDESCFORM').hide();
            popupobj.center();
        }
    })*/

    ld('#'+popupobj.divid).find(' [name=td_cmb_activitystate]>b').hide();
    ld('#'+popupobj.divid).find(' [name=td_cmb_mappingmodule]>b').hide();
    ld('#'+popupobj.divid).find(' [name=td_cmb_social_activitytype]>b').hide();

    //默认映射为客户 页面加载完成后请求html
    var record = ld('#'+popupobj.divid+' [name=record]').val();
    getCustomFieldHtml('Accounts',record,'create');
    //监听映射模块内容改变
    ld('#'+popupobj.divid+' [name =cmb_ul_mappingmodule]').on("click",'li',function() {
        var mappingmodule = ld('#' + popupobj.divid + ' [name=mappingmodule]').val();
        getCustomFieldHtml(mappingmodule,'','changemodule')
    });
})

// 活动类型
function changeSocialActivitytype(obj){

    var popupobj = CrmPopup.getPopupObj("last");
	if(obj.value == activitytypeArr.onlyForm ){
		ld('#'+popupobj.divid+ ' [name=h5pageurl]').parent().parent().hide();
		ld('#'+popupobj.divid+ ' [name=h5pagebutton]').parent().parent().hide();
		ld('#'+popupobj.divid+ ' [name=h5buttoncolor]').parent().parent().hide();
		ld('#'+popupobj.divid+ ' #ACTIVITYH5PAGEHELP').hide();
		ld('#'+popupobj.divid+ ' #ACTIVITYDESCH5ANDFORM').hide();
		ld('#'+popupobj.divid+ ' #ACTIVITYDESCFORM').show();
		popupobj.center();
	}else{
		ld('#'+popupobj.divid+ ' [name=h5pageurl]').parent().parent().show();
		ld('#'+popupobj.divid+ ' [name=h5pagebutton]').parent().parent().show();
		ld('#'+popupobj.divid+ ' [name=h5buttoncolor]').parent().parent().show();
		ld('#'+popupobj.divid+ ' #ACTIVITYH5PAGEHELP').show();
		ld('#'+popupobj.divid+ ' #ACTIVITYDESCH5ANDFORM').show();
		ld('#'+popupobj.divid+ ' #ACTIVITYDESCFORM').hide();
		popupobj.center();
	}
}
