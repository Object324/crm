 function PopupDrag(popupobj,divid)
{
   
     var that=this;
     this.popupobj=popupobj;
     
     this.popupobj.oWin = document.getElementById(divid);
     //var popupobj=CrmPopup.getPopupObj('last');
      this.popupobj.oHead = document.getElementById(divid+"_head");
      var oHead=document.getElementById(divid+"_head");
      if(oHead==undefined)
      {
        return false;
      }
     popupobj.bDrag = false;
      this.popupobj.disX =  this.popupobj.disY = 0;
        if(document.attachEvent){
           
            //IE:拖动禁止选中文字
                oHead.attachEvent('onselectstart', function() {
                    return false;
                });
            }
        
     this.popupobj.oHead.onmousedown = function (event)
     {  
		
        var popupobj=CrmPopup.getPopupObj('last');
          var event = event || window.event;
          if(popupobj.oWin==undefined){
            return false;
         }
          popupobj.bDrag = true;
         
          popupobj.disX = event.clientX - popupobj.oWin.offsetLeft;
          popupobj.disY = event.clientY - popupobj.oWin.offsetTop;  
          popupobj.oHead.setCapture && popupobj.oHead.setCapture();  
          return true
     };

    this.handleMousemove = function(event) {
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj==undefined) return false;
        if (!popupobj.bDrag) {return;}
        var event = event || window.event;
        var iL = event.clientX - popupobj.disX;
        var iT = event.clientY - popupobj.disY;
        var maxL = document.documentElement.clientWidth - popupobj.oWin.offsetWidth;
          //30632: 客户新建界面>城市弹出层：点击头部当前弹出层会移动。
        var maxT = document.documentElement.scrollHeight - popupobj.oWin.offsetHeight;  
        iL = iL < 0 ? 0 : iL;
        iL = iL > maxL ? maxL : iL;   
        iT = iT < 0 ? 0 : iT;
        iT = iT > maxT ? maxT : iT;
        
        //   oWin.style.marginTop = oWin.style.marginLeft = 0;
        popupobj.oWin.style.left = iL + "px";
        popupobj.oWin.style.top = iT + "px";  
        
        return false
    }
    document.addEventListener('mousemove', this.handleMousemove);//BUG0071843 xxy 2023-8-31 mousemove改为监听，并在关闭弹窗时remove掉监听 后台设置-登录策略-点击编辑规则，然后关闭，规则无法拖动，页面文字也无法选中复制（谷歌跟edge浏览器有此情况）

     document.onmouseup = window.onblur = oHead.onlosecapture = function ()
     {
            var popupobj=CrmPopup.getPopupObj('last');
            if(popupobj==undefined){
                return false;
            }
            if(popupobj!=undefined&&popupobj.bDrag!=undefined)
                  popupobj.bDrag = false;    
           //console.log(popupobj.divid);
           if(popupobj.oHead!=undefined)
                popupobj.oHead.releaseCapture && popupobj.oHead.releaseCapture();
     };
};