var popupobj=CrmPopup.getPopupObj("last");
popupobj.before_validate=function()
{
     var popupobj=CrmPopup.getPopupObj("last");
      var divid=popupobj.divid;
      
     var publicaccount=CrmPopup.findHtmlobj(divid,"publicaccount").val();
    var record=CrmPopup.findHtmlobj(divid,"record").val();
	var cur_this=this;
    var bol=true;
     if(publicaccount==2&&(record==''||record==0))
     {
         var userid=CrmPopup.findHtmlobj(divid,'assigned_user_id').find("option:selected").val();
         var username=CrmPopup.findHtmlobj(divid,'assigned_user_id').find("option:selected").text();
         
         var max_url="module=Accounts&action=AllocateAccount&allocatetype=3&maxaccount=1&ReportHeader=dheader&userid="+userid+"&type=createpage";
        
          ld.ajax({
                    type : "post",
                    url : "index.php",
                    data : max_url,
                    async:false,
                    success : function(response) {
                       
                        if(response.indexOf('error')!='-1')
                        {
                                           confirm_str = username+arrJsPopLabel['HIGHSEASREACHEDTHELIMITALLOCATION'];
                                           audioRemindsMsg("","","","","",confirm_str);
                                          // alert(confirm_str);
                                           bol= false;
                        }
                    }
                });
                
     }
    if(bol)
      return AccontContactValidate();
                                                
      
}
popupobj.after_validate=function()
{
  
 
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var accountname = CrmPopup.getHtmlobjval(divid,'accountname');

    var record =CrmPopup.getHtmlobjval(divid,'record');
    var ret=false;
    ld.ajax({
        type : "post",
        url : "index.php",
        data : "record="+record+"&fieldname=accountname&fieldvalue="+accountname+"&module=Accounts&module=Accounts&file=AccountsNameHedging&action=AccountsAjax",
        async:false,
        success : function(response) {
          
            if (response.indexOf('##NOTHING##')>=0 ) {
              
               ret=true;
            } else {

                createElementDiv('DivAccountRemind');//创建DIV
               
                ld('#DivAccountRemindtitlename').html(arrJsPopLabel['REMINDHEDGING']);
                sethtml
                (
                    document.getElementById('DivAccountRemindcontent'),
                    '<div style="font-size: 12px;">' + response + '</div>'
                );
                ld('#DivAccountRemind .D_pbtn .D_pbtnok').unbind('click').on('click', function () {
                    fninvshnew('DivAccountRemind');
                });
                ld('#DivAccountRemind .D_pbtn .D_pbtncancel').css('display', 'none');
               ret=false;
            }
        }
    });
   return ret;
}

 popupobj.before_duplicate=function()
{
    
    //重复客户不能保存。需“客户名称”+“保护产品”两个字段都重复时，方不能保存。保护产品是下拉框，内容已设好。
    //信淼传媒的客户保护查重要求如下，请安排开发，尽早交付给客户。该功能是使用的第一步，其他功能都已实施好了。（xiaoshou360.com/xinmiao)
     var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;

    var record =CrmPopup.getHtmlobjval(divid,'record');
    var ret=false;
  
    if(CrmPopup.isExistsObj(divid,"cf_1743"))
    {
        var tagname=CrmPopup.findHtmlobj(divid,"cf_1743").prop("tagName");
        
        if(tagname.toLocaleLowerCase()=='select')
        {
          
            var cf_1743=CrmPopup.findHtmlobj(divid,"cf_1743").find("option:selected").val();
            var accountname = CrmPopup.getHtmlobjval(divid,'accountname');
             ld.ajax({
                    type : "post",
                    url : "index.php",
                    data : "id="+record+"&accoutname="+accountname+"&productname="+cf_1743+"&module=Accounts&file=accountnameproductDup&action=AccountsAjax",
                    async:false,
                    success : function(response) {
                       alert(response);
                        if (response.indexOf('##dupNOTHING##')>=0 ) {
                           
                            ret= true;
                           
                        } else {
                           RemindsMsg("","LdPopWidth400px","","yes","",results[1]);
                            ret= false;
                        }
                    }
                });
        }
        else
        {
            return true;
        }
       
        
    }
    else
    {
       
        return true;
    }
       
     return ret;
}

/*
edit:can
date:20131010
reason:客户编辑界面首要联系人逻辑判断
*/
function AccontContactValidate()
{

    var form=document.forms['EditView'];
    if(form.lastname==undefined)
    {
         return true;
    }
   

    if(trim(form.lastname.value)==""&&((form.firstname!=undefined&&trim(form.firstname.value)!="")||trim(form.title.value)!=""
        ||(form.mobile!=undefined&&trim(form.mobile.value)!="")||(form.email!=undefined&&trim(form.email.value)!="")||

        (form.qq!=undefined&&trim(form.qq.value)!="")))
    {
        //首要联系人姓名不能为空！
        var confirm_str = arrJsPopLabel['CONTACTNAMECANOTEMPTY'];
        audioRemindsMsg("","","","","",confirm_str);
        form.lastname.focus();
        return false;
    }
 
    /*
    edit:can
    date:20140211
    reason:6698: 客户，新增客户界面，首要联系人列，没有对邮箱格式进行限制，如图：
    */
    
    var re=new RegExp(/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/);
    
     if(form.email!=undefined&&trim(form.email.value)!=""&&!re.test(trim(form.email.value)))
    {
        //首要联系人Email格式错误
        var confirm_str = arrJsPopLabel['CONTACTEMAILFORMATERROR'];
        audioRemindsMsg("","","","","",confirm_str);
        form.email.focus();//add lmx 20140225   0007200 客户新增界面，首要联系人列表，邮件格式设置出错时，点击保存，弹出提示信息，点击确定，光标没有定位；
        return false;
    }
     
    return true;
}
//chj 界面显示后，加载腾讯地图
 popupobj.showafter=function()
{
   
	getLocationAddress('locationaddress','edit');
}