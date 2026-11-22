//ls XUQIU1001284 【百特】拜访记录模块，新增编辑时，【邀请手机号】cf_6314字段旁边增加一个发送按钮，使用阿里的短信接口来发送短信
function sendsmsBaxter(obj,record){
    // var mobilePhone = ld(obj).prev("input").val();
    var popupobj=CrmPopup.getPopupObj("last");
    // console.log(popupobj);
    var mobile = ld(obj).prev("input[name=cf_6314]").val();
    var cf_6305 = ld("#"+popupobj.divid+" input[name=cf_6305]").val() || "";//病人编号
    var contactdate = ld("#"+popupobj.divid+" input[name=contactdate]").val() || "";//病人编号
    var reg = new RegExp('^1[3456789]\\d{9}$');
    if (!reg.test(mobile)) {
        alert("手机号码格式错误，请重新输入！");
        return false;
    }
    if(confirm('确定发送邀请短信?')){
        var urlstring = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=Baxter&mode=sendsms';
        ldAjax(urlstring,{"mobile":mobile,"cf_6305":cf_6305,"contactdate":contactdate},function(data){
            // console.log(data);
            if(data.code == 1){
                // 新建编辑界面。cf_6315 推广微信次数字段+1。
                var cf_6315 = parseInt(ld("#"+popupobj.divid+" [name=cf_6315]").val()) || 0;
                CrmPopup.findHtmlobj(popupobj.divid,'cf_6315').val(cf_6315+1);
                CrmPopup.findHtmlobj(popupobj.divid,'span_cf_6315').html(cf_6315+1);
            }
            RemindsMsg("","LdPopWidth400px","","yes","",data.msg);

        })
    } 

}