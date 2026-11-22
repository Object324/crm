 var docEle = function() {
            return document.getElementById(arguments[0]) || false;
        }

        function openNewDiv(_id) {
            var m = "mask";
            if (docEle(_id)) document.body.removeChild(docEle(_id));
            if (docEle(m)) document.body.removeChild(docEle(m));

            //mask遮罩层
            var newMask = document.createElement("div");
            newMask.id = m;
            newMask.style.position = "absolute";
            newMask.style.zIndex = "11000";
            _scrollWidth = Math.max(document.body.scrollWidth, document.documentElement.scrollWidth);
            _scrollHeight = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight);
            newMask.style.width = _scrollWidth + "px";
            newMask.style.height = _scrollHeight + "px";
            newMask.style.top = "0px";
            newMask.style.left = "0px";
            newMask.style.background = "#333";
            newMask.style.filter = "alpha(opacity=100)";
            newMask.style.opacity = "0.8";
            document.body.appendChild(newMask);
	
            //新弹出层
            var newDiv = document.createElement("div");
            newDiv.id = _id;
            newDiv.style.position = "absolute";
            newDiv.style.zIndex = "11001";
            newDivWidth = 300;
            newDivHeight = 104;
            newDiv.className='E_pop_box LdPopWidth200px';
            newDiv.style.width = newDivWidth + "px";
            newDiv.style.height = newDivHeight + "px";
            newDiv.style.top = 150 + "px";
            newDiv.style.left = (document.body.scrollLeft + document.body.clientWidth / 2 - newDivWidth / 2) + "px";
            //newDiv.innerHTML = "<div class='divClose'><a href='javascript:void' onclick='closeNewDiv()'></a>"+arrJsPopLabel['REMINDER']+"</div> <p>"+arrJsPopLabel['BACKINGUPDATABASE']+"......</p>";
            newDiv.innerHTML =  "<div class='E_pop_tit'>"+
                                    "<strong class='E_ptita'>"+arrJsPopLabel['REMINDER']+"</strong>"+
                                    "<button class='E_ptitc' value='"+arrJsPopLabel['LBL_CLOSE']+"' onclick=\"fninvshnew(\'newDiv\');fninvshnew(\'mask\')\"></button>"
                                "</div>";
            newDiv.innerHTML +="<div style='text-align: center;padding: 16px 0;'>"+arrJsPopLabel['BACKINGUPDATABASE']+"......</div>";
            
            document.body.appendChild(newDiv);

            //弹出层滚动居中
            function newDivCenter() {
				if(typeof(newDiv) == "undefined") return false;
                newDiv.style.top = (document.body.scrollTop + document.body.clientHeight / 2 - newDivHeight / 2 -200) + "px";
                newDiv.style.left = (document.body.scrollLeft + document.body.clientWidth / 2 - newDivWidth / 2) + "px";
            }
            if (document.all) {
                window.attachEvent("onscroll", newDivCenter);
            }
            else {
                window.addEventListener('scroll', newDivCenter, false);
            }
          
          
        
        }
        
        function openNewDivExport(_id,count,num,type) {
            var m = "mask";
            if (docEle(_id)) document.body.removeChild(docEle(_id));
            if (docEle(m)) document.body.removeChild(docEle(m));
            var exportbegin=1+(200*(num-1));
            var exportend=200*num;
            //mask遮罩层
            var newMask = document.createElement("div");
            newMask.id = m;
            newMask.style.position = "absolute";
            newMask.style.zIndex = "11000";
            _scrollWidth = Math.max(document.body.scrollWidth, document.documentElement.scrollWidth);
            _scrollHeight = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight);
            newMask.style.width = _scrollWidth + "px";
            newMask.style.height = _scrollHeight + "px";
            newMask.style.top = "0px";
            newMask.style.left = "0px";
            newMask.style.background = "#333";
            newMask.style.filter = "alpha(opacity=100)";
            newMask.style.opacity = "0.8";
            document.body.appendChild(newMask);
	
            //新弹出层
            var newDiv = document.createElement("div");
            newDiv.id = _id;
            newDiv.style.position = "absolute";
            newDiv.style.zIndex = "11001";
            newDivWidth = 650;
            newDivHeight = 90;
            newDiv.className='E_pop_box LdPopWidth200px'
            newDiv.style.width = newDivWidth + "px";
            newDiv.style.height = newDivHeight + "px";
            newDiv.style.top = 150 + "px";
            newDiv.style.left = (document.body.scrollLeft + document.body.clientWidth / 2 - newDivWidth / 2) + "px";
            //newDiv.innerHTML = "<div class='divClose'><a href='javascript:void' onclick='closeNewDiv()'></a>"+arrJsPopLabel['REMINDER']+"</div> <p>"+arrJsPopLabel['BACKINGUPDATABASE']+"......</p>";
            if(type=='export'){
               
                 if(count.toLowerCase().indexOf('details')>0)
                 {
                     var spcounts=count.split('details');
                     count=spcounts[0];
                    
                     var detailcount=spcounts[1];
                  
                    newDiv.innerHTML = "<div class='E_pop_tit'><strong class='E_ptita'>"+arrJsPopLabel['REMINDER']+"</strong></div>";
                    newDiv.innerHTML +="<table class='D_pop_bod' width='100%' border='0' cellspacing='1' cellpadding='1'><tr><td>"+arrJsPopLabel['ATOTALOF']+count+arrJsPopLabel['DETAILRECORDSEXPORTING']+detailcount+arrJsPopLabel['DETAILRECORDSEXPORTINGNEXT']+exportbegin+arrJsPopLabel['EXPORTTO2']+exportend+arrJsPopLabel['PLEASEWAITFORAMOMENT']+"</td></tr></table>";
                 }
                 else
                 {
                    newDiv.innerHTML = "<div class='E_pop_tit'><strong class='E_ptita'>"+arrJsPopLabel['REMINDER']+"</strong></div>";
                    newDiv.innerHTML +="<table class='D_pop_bod' width='100%' border='0' cellspacing='1' cellpadding='1'><tr><td>"+arrJsPopLabel['ATOTALOF']+count+arrJsPopLabel['RECORDSEXPORTING']+exportbegin+arrJsPopLabel['EXPORTTO2']+exportend+arrJsPopLabel['PLEASEWAITFORAMOMENT']+"</td></tr></table>";
                 }
                 
                
            }else if(type=='import'){
                newDiv.innerHTML = "<div class='E_pop_tit'><strong class='E_ptita'>"+arrJsPopLabel['REMINDER']+"</strong></div>";
                newDiv.innerHTML +="<table class='D_pop_bod' width='100%' border='0' cellspacing='1' cellpadding='1'><tr><td>"+arrJsPopLabel['ATOTALOF']+count+arrJsPopLabel['RECORDSIMPORTING']+exportbegin+arrJsPopLabel['EXPORTTO2']+exportend+arrJsPopLabel['PLEASEWAITFORAMOMENT']+"</td></tr></table>";
            }
        
            document.body.appendChild(newDiv);

            //弹出层滚动居中
            function newDivCenter() {
				if(typeof(newDiv) == "undefined") return false;
                newDiv.style.top = (document.body.scrollTop + document.body.clientHeight / 2 - newDivHeight / 2 -200) + "px";
                newDiv.style.left = (document.body.scrollLeft + document.body.clientWidth / 2 - newDivWidth / 2) + "px";
            }
            if (document.all) {
                window.attachEvent("onscroll", newDivCenter);
            }
            else {
                window.addEventListener('scroll', newDivCenter, false);
            }
          
          
        
        }
          function newDivCenter() {
			  if(typeof(newDiv) == "undefined") return false;
                newDiv.style.top = (document.body.scrollTop + document.body.clientHeight / 2 - newDivHeight / 2 -200) + "px";
                newDiv.style.left = (document.body.scrollLeft + document.body.clientWidth / 2 - newDivWidth / 2) + "px";
            }
            if (document.all) {
                window.attachEvent("onscroll", newDivCenter);
            }
            else {
                window.addEventListener('scroll', newDivCenter, false);
            }
          function closeNewDiv()
            {
                 if (document.all) {
                    window.detachEvent("onscroll", newDivCenter);
                }
                else {
                    window.removeEventListener('scroll', newDivCenter, false);
                }
                if(docEle('newDiv'))
                {
                    document.body.removeChild(docEle('newDiv'));
                    document.body.removeChild(docEle('mask'));
                    
                }
                    
                return false;
            }