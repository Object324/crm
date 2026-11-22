 var docEle = function() {
            return document.getElementById(arguments[0]) || false;
        }
var newDiv=undefined;
        function openNewDiv(_id) {
            var m = "mask";
            if (docEle(_id)) document.body.removeChild(docEle(_id));
            if (docEle(m)) document.body.removeChild(docEle(m));

            //mask遮罩层
            var newMask = document.createElement("div");
            newMask.id = m;
            newMask.style.position = "absolute";
            newMask.style.zIndex = "10000";
            _scrollWidth = Math.max(document.body.scrollWidth, document.documentElement.scrollWidth);
            _scrollHeight = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight);
            newMask.style.width = _scrollWidth + "px";
            newMask.style.height = _scrollHeight + "px";
            newMask.style.top = "0px";
            newMask.style.left = "0px";
            newMask.style.background = "#333";
            newMask.style.filter = "alpha(opacity=100)";
            newMask.style.opacity = "0.8";
            //document.body.appendChild(newMask);
	
            //新弹出层
             newDiv = document.createElement("div");
            newDiv.id = _id;
            newDiv.style.position = "absolute";
            //newDiv.style.zIndex = "11000";
            newDivWidth = 390;
            newDivHeight = 84;
            newDiv.className='noResultBG'
            //newDiv.style.width = newDivWidth + "px";
            //newDiv.style.height = newDivHeight + "px";
        
            //document.body.scrollTop + document.body.clientHeight+
            //newDiv.style.top = ((document.documentElement.clientHeight  - newDiv.offsetHeight)/2+document.documentElement.scrollTop-newDivHeight/2) + "px";
            newDiv.style.top="25%";
            newDiv.style.left = (document.body.scrollLeft + document.body.clientWidth / 2 - newDivWidth / 2) + "px";
            //newDiv.innerHTML = "<div class='divClose'><a href='javascript:void' onclick='closeNewDiv()'></a>"+arrJsPopLabel['REMINDER']+"</div> <p>"+arrJsPopLabel['RUNNINGPLEASEWAIT']+"......</p>";
            //newDiv.innerHTML = "<div class='Title'><img src='themes/softed/tier/icon_loto.png' class='Logo' /><span class='Name'>"+arrJsPopLabel['REMINDER']+"</span><a href='javascript:void' onclick='closeNewDiv()'><img src='themes/softed/tier/icon_close.png' class='Close' />";
            //newDiv.innerHTML +="</a></div><div class='Content_div'><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr><td class='Note'>"+arrJsPopLabel['RUNNINGPLEASEWAIT']+"......</td></tr></table></div>";
            
            /*by andy 页面改进20140805*/
            var mailmangediv = "<div class='noResultContent'>";
            mailmangediv+="<div class='divNoRecord'>"+arrJsPopLabel['RUNNINGPLEASEWAIT']+"......</div></div>";
            newDiv.innerHTML = mailmangediv;
            document.body.appendChild(newDiv);

            //弹出层滚动居中
            function newDivCenter() {
            
                newDiv.style.top = newDiv.style.top = ((document.documentElement.clientHeight  - newDiv.offsetHeight)/2+document.documentElement.scrollTop-newDivHeight/2 ) + "px";
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
                if(newDiv!=undefined)
                {
                 
                
                    newDiv.style.top = ((document.documentElement.clientHeight  - newDiv.offsetHeight)/2+document.documentElement.scrollTop-newDivHeight/2 ) + "px";
                    newDiv.style.left = (document.body.scrollLeft + document.body.clientWidth / 2 - newDivWidth / 2) + "px";
                }
               
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