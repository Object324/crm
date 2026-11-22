function cls_ShortKey(popupobj)
{
    //键盘快捷键事件 ,方向键 回车键
    var that=this;
    that.popupobj=popupobj;
    that.action="enterDirection";//方向键+回车键
    this.selectobj=undefined;
    that.selectedtype="";
    that.selectedname=''
    that.excludeobj=undefined;
    this.setFromPopupobj=function(popupobj)
    {
        that.popupobj=popupobj
    }
    this.setEventByTag=function(TriggerDirectionobj,directionparentobj,htmlEletag,directioncallback,entercallbackfun)
    {
        that.selectcallbackfun=entercallbackfun;
        that.directioncallback=directioncallback;
        that.directionparentobj=directionparentobj;
        that.htmlEletag=htmlEletag;
        that.firstobj=ld(directionparentobj).find(htmlEletag).first();
       
        that.lastobj=ld(directionparentobj).find(htmlEletag).last();
     
      
      ld(TriggerDirectionobj).off("keyup",that.TriggerDirectionobjkeyupEvent)
        
       ld(TriggerDirectionobj).on("keyup",that.TriggerDirectionobjkeyupEvent);
       
       ld(directionparentobj).find(htmlEletag).on("keyup",that.htmlEletagkeyupEvent)
        ld(document.body).on("keyup",that.htmlEletagkeyupEvent)
         
        
    }
    this.setSelectedClassName=function(classname)
    {
        this.selectedtype='class';
        this.selectedname=classname;
    }
    this.setselectedType=function(type,name)
    {
        that.selectedtype=type;
        this.selected=name;
        
    }
    this.setexcludeobj=function(excludeobj)
    {
        that.excludeobj=excludeobj;
    }
     this.setEventByClass=function(TriggerDirectionobj,directionparentobj,htmlClassName,directioncallback,entercallbackfun)
    {
      
        that.selectcallbackfun=entercallbackfun;
        that.directioncallback=directioncallback;
        that.directionparentobj=directionparentobj;
        that.htmlClassName=htmlClassName;
        that.firstobj=ld(directionparentobj).find(" ."+htmlClassName).first();
       
        that.lastobj=ld(directionparentobj).find(" ."+htmlClassName).last();
  
    
        TriggerDirectionobj.off("keyup",that.TriggerDirectionobjkeyupEvent);
       TriggerDirectionobj.on("keyup",that.TriggerDirectionobjkeyupEvent);
      
        ld(directionparentobj).find(" ."+htmlClassName).off("keyup",that.htmlEletagkeyupEvent)
        ld(directionparentobj).find(" ."+htmlClassName).on("keyup",that.htmlEletagkeyupEvent)
         ld(document.body).on("keyup",that.htmlEletagkeyupEvent)
        
    }
    this.TriggerDirectionobjkeyupEvent=function(event){
        
       
         that.setKeyCodeAction(event);
          
          
           
    }
    that.htmlEletagkeyupEvent=function(event)
    {
       
        that.setKeyCodeAction(event);
        
    }
    that.setKeyCodeAction=function(event)
    {
        if (event.keyCode !=13 && event.keyCode!=38 && event.keyCode!=40 ){
            return false;
        }
        //搜索后需要重新定义firstobj
        if (!empty(that.htmlClassName)){
            that.firstobj=ld(that.directionparentobj).find(" ."+that.htmlClassName).first();
        }
        else if(!empty(that.htmlEletag)){
            that.firstobj=ld(that.directionparentobj).find(that.htmlEletag).first();
        }

        if(that.selectedname!='')
        {
            if(that.selectedtype=='class')
            {
            that.selectobj=ld(that.directionparentobj).find(" ."+that.selectedname);
               
            }
            
        }
        if(event.keyCode==13)
        {

            if(that.selectobj!=undefined&&that.selectcallbackfun!=undefined&&that.selectobj.length>0)
            {
                that.selectcallbackfun(event,that.selectobj);
            }
            StopEvent(event.originalEvent);
            return false;
        }
       
            
        var isaction=false;
        if(event.which == 38 || event.keyCode == 38){
            // 按下了上箭头键，执行相关操作

            if(that.selectobj!=undefined&&that.selectobj.prevAll(':first')!=undefined&&that.selectobj.prevAll(':first').length>0)
            {
                if(that.htmlClassName!='' && that.htmlClassName !=undefined)
                {
                    var data_groupindex=ld(that.selectobj).prevAll(':first').attr('data-groupindex');
                    if (!empty(data_groupindex) || data_groupindex!=undefined){
                        that.selectobj=ld(that.selectobj).prevAll(':first');
                    }
                    if(!ld(that.selectobj).prevAll(':first').hasClass(that.htmlClassName))
                        return ;
                }
                that.selectobj=ld(that.selectobj).prevAll(':first');
            }else {
                    that.selectobj=ld(that.firstobj);
            }
             StopEvent(event.originalEvent)
             isaction=true;
         //   event.preventDefault();  // 阻止默认的按键行为
          }
          if(event.which == 40 || event.keyCode == 40){
            // 按下了下箭头键，执行相关操作
                if(ld(that.selectobj).nextAll(':first')!=undefined&&ld(that.selectobj).nextAll(':first').length>0)
               {
                   if(that.htmlClassName!=''&&that.htmlClassName!=undefined)
                   {
                       var data_groupindex=ld(that.selectobj).nextAll(':first').attr('data-groupindex');
                       if (!empty(data_groupindex) || data_groupindex!=undefined){
                           that.selectobj=ld(that.selectobj).nextAll(':first');
                       }
                        if(!ld(that.selectobj).nextAll(':first').hasClass(that.htmlClassName))
                            return ;
                   }
                 that.selectobj=ld(that.selectobj).nextAll(':first');
               }
               else{
                    that.selectobj=ld(that.firstobj);
               }
             StopEvent(event.originalEvent)
             isaction=true;
          }
          if(event.which == 37 || event.keyCode == 37){
            // 按下了左箭头键，执行相关操作
           
          }
          if(event.which == 39 || event.keyCode == 39){
            // 按下了右箭头键，执行相关操作
            
          }
          if(event.which == 33||event.keyCode==33)
          {
            //page up
           // event.preventDefault();  // 阻止默认的按键行为
          }
           if(event.which == 34||event.keyCode==34)
          {
            //page down
            //event.preventDefault();  // 阻止默认的按键行为
          }
        
          if(isaction==true)
          {
                if(that.selectobj!=undefined)
              {
               //ld(that.selectobj).attr("tabindex",999999)
                that.selectobj.focus();

               //跟随滚动条效果
                  if (ld(that.selectobj).offset() != undefined){
                      var newLiOffset = ld(that.selectobj).offset().top;
                      var scrollDistance = newLiOffset - ld(that.directionparentobj).offset().top;
                      ld(that.directionparentobj).animate({scrollTop: '+=' + scrollDistance}, 100);
                  }
              }
              
               if(that.directioncallback!=undefined)
               {
                    that.directioncallback(event,that.selectobj);
                
               }
          }
           
    }
}
 