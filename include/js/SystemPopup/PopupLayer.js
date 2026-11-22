//弹出层遮罩层
function CrmPopupLayer(popupobj)
{
        this.popupblockid=popupobj.divid+"_popupblock";
        this.opopupblocknodeid=popupobj.divid+"_olayernodeid";
        
    	this._olayer= function(toggle) {
    		
    		this._removebyid(this.popupblockid);
    	   if(typeof(toggle) == 'undefined' || !toggle) return;
    		var olayer = document.getElementById(this.popupblockid);
    		if(!olayer) {
    			olayer = document.createElement("div");
    			olayer.id = this.popupblockid;
    			olayer.className = "small veil veil_p";
    			olayer.style.zIndex = 1;
    			if(olayer.style.zIndex < 0) olayer.style.zIndex *= -1;
    			if (browser_ie) {
    				olayer.style.height = document.body.offsetHeight + (document.body.scrollHeight - document.body.offsetHeight) + "px";
    			} else if (browser_nn4 || browser_nn6) {
    				olayer.style.height = document.body.offsetHeight + "px";
    			}
    			olayer.style.width = "100%";
                olayer.style.height = "100%";
                olayer.style.left=0;
                olayer.style.top=0;
    			document.body.appendChild(olayer);
                ld("#"+this.popupblockid).unbind("click").bind("click",function(){
                    //Accounts_pagerecord1102_btncancel
                    //40575: （51mis.com/kfbtest）去除单据新增、编辑界面点击页面空白处，自动关闭当前页面功能，详情界面保留该功能。
                    if(popupobj.type==DetailViewPage.type)
                            ld("#"+popupobj.divid+"_imgclose").get(0).click();
                    
                })
                 document.getElementById(this.popupblockid).onclick=function()
                {
                    //edit:can 2020-09-19 42700: （61mis.com/kfbcrm）合同订单模块>新建单据界面：单据分录中的下拉框，点开了，如果不选择，没法关掉这个下拉框的弹出层
                    ld(" .chzn-drop").css("display",'none');
                }
    		}
    		if(olayer) {
                
    		   olayer.style.zIndex = CrmPopup.zIndex-1;
               CrmPopup.zIndex++;
    			if(toggle) olayer.style.display = "block";
    			else olayer.style.display = "none";
    		}
    		return olayer;
    	}
    	this._removebyid= function(id) {
    		if(ld(id)) ld(id).remove();
    	}
    	this.unblock=function() {
    	   if(document.getElementById(this.popupblockid))
           {
                var layer=document.getElementById(this.popupblockid);
                layer.style.display="none";
                document.body.removeChild(layer); 
           }
           if(document.getElementById(this.opopupblocknodeid))
           {
            var olayer=document.getElementById(this.opopupblocknodeid);
            olayer.style.display = "none";
            document.body.removeChild(olayer);
           }
    	}
    	this.block =function(opacity) {
    	  if(!document.getElementById(this.popupblockid)&&!document.getElementById(this.opopupblocknodeid)){
        		if(typeof(opactiy)=='undefined') opacity = '0.5';
        		var olayernode = this._olayer(true); 
                olayernode.id=this.opopupblocknodeid;     
                olayernode.className = 'mask opacity';
        		olayernode.style.opacity = opacity;
               
           }
           
    	}
    
    
    
}
