/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
function CreateSysCode(obj) {
    window.location.href="Register/RegLogin.php?action=syscode";
    return false;
}
function closeRegisterabount() {
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.CancelEvent();
}
closeRegisterabount.funname='closeRegisterabount';
function ShowAbout(event) {

     var module='Register';
     var Popupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
     var url='Register/RegLogin.php?action=about';
     ld.ajax({
        url: url,
        type: 'POST',
        contentType:"application/json;charset=utf-8",
        data:{"namename": "uname", "namenameage": 18},
        dataType:'json',
        async: true,
        timeout: 60000,
        success: function(data){
            if(data.code==1){
                Popupobj.prevshow();
                Popupobj.setParams(data.result.title,closeRegisterabount,"","LdPopWidth600px","about","",data.result.oktext,"","");
                Popupobj.createScrollDiv();//创建滚动条
                Popupobj.show(data.result.content);
                ld('#'+Popupobj.divid+' .dvpopupsroll').css('margin','0');
                ld('#'+Popupobj.divid+' .dvpopupsroll').css('max-height','420px');
				Popupobj.center();
                return Popupobj;
            }
            else
            {
                window.location.href="index.php?action=isReg";

            }
        },
        error:function(data)
        {}
    });
}
 var httpreq=null;
function fileupLoad(urlparam) {
    httpreq=createXMLHTTP();
    httpreq.open("POST",urlparamurlparam,true);
    httpreq.onreadystatechange=SessionRequest;
    httpreq.setRequestHeader("If-Modified-Since","0");
    httpreq.send(null);
}
function SessionRequest(){
    if(httpreq.readyState==4){
        if(httpreq.status==0||httpreq.status==200){
        }
    }
}
function fileclick(event) {
    var obj=document.getElementById('upload_test');
    obj.style.display="block";
    return false;
}
function btnFilesubmit(event) {


    var e=event||window.event;
    var obj=e.srcElement||e.target ;
    var filename=obj.value;
    if(filename.split('.')[filename.split('.').length-1].toLowerCase()!="dat") {
    }
    document.getElementById("registersubmit").click();

}