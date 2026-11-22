function ProgressPopup(){
    var parentshow=this.show;
    this.parentfun_show = parentshow;
    this.show=function()
    {
        var htmlcontent="<div class='import_process'><div class='progressbar batchProgress'></div>";
        htmlcontent+="<div class='import_info'>共选择了<span class='num totalnum'></span>条记录，<span class='spanvalidata' style='display:none'>有效操作记录<span class='num validatanum'></span>条，</span> 正在操作第<span class='num curnum'></span>条记录，请稍后……</div></div>";
        //zkt 20220406 50811: （81mis.com/kfbcrm）联系人》全选，分配给系统管理员，进度条最后会超出弹窗一点点
        this.cssWidth=600;
        parentshow.apply(this,[htmlcontent]);  //调用父类show()函数
        // ld("#"+this.divid+" .progressbar").css("background-color",'#6abd3d');
        
        // ld("#"+this.divid+" .progressbar").css("height","30px");
        ld("#"+this.divid).css("zIndex",10000);
    }
    this.setPercentWidth=function(percent)
    {
        if(percent==''||percent==0)
        {
            ld("#"+this.divid+" .progressbar").css("width","0px");
            ld("#"+this.divid+" .progressbar").html('');
            
            return ;
        }
        if(percent>100)
        {
            percent=100;
        }
        var maxwidth= parseInt(ld("#"+this.divid+" .import_process").css("width"),10);
        var width=parseInt(maxwidth*percent/100,10);
        ld("#"+this.divid+" .progressbar").html(percent+"%");
        if(percent>0)
        {
           
            if(width<25)
            {
                width=25;
            }
        }
        ld("#"+this.divid+" .progressbar").css("width",width+"px");
        
    }
    this.setTotalNum=function(totalnum){
        ld("#"+this.divid+" .totalnum").html(totalnum);
        
    }
    this.setCurNum=function(curnum)
    {
        ld("#"+this.divid+" .curnum").html(curnum);
        
    }
    this.setValidataNum=function(validatanum)
    {
        ld("#"+this.divid+" .spanvalidata").css("display",'');
        ld("#"+this.divid+" .validatanum").html(validatanum);
    }
    this.setcuruser=function(curuser)
    {
        ld("#"+this.divid+" .curuser").html(curuser);
    }
    this.setusername=function(username)
    {
        ld("#"+this.divid+" .username").html(username);
    }
    this.showhtml=function(html)//进度条下方注释特殊显示
    {
        var htmlcontent=html;
        this.cssWidth=670;
        parentshow.apply(this,[htmlcontent]);  //调用父类show()函数
        ld("#"+this.divid).css("zIndex",10000);
    }
}


ProgressPopup.type='ProgressPopup';
ProgressPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText)
{
      ProgressPopup.prototype=new CrmPopup();  
      ProgressPopup.prototype.constructor=ProgressPopup;  
      ProgressPopup.prototype.type=ProgressPopup.type;
     var  ProgressPopupobj=new ProgressPopup();
     ProgressPopupobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return ProgressPopupobj;

}

