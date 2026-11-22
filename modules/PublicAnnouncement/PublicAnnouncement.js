/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/		
		
document.write("<script type='text/javascript' src='include/js/Mail.js'></"+"script>");

/**
 *@edit:andy 
 *@date:20140909
 *@reason:左右选择项改进
 *@version:
 */
 if (document.all)

	var browser_ie=true

else if (document.layers)

	var browser_nn4=true

else if (document.layers || (!document.all && document.getElementById))

	var browser_nn6=true
function copySelectedOptionsPubModule(source, destination) {

    var srcObj = document.getElementById(source);//$(source);
	var destObj = document.getElementById(destination);//$(destination);
	if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    for (i=0;i<srcObj.length;i++) {
		if (srcObj.options[i].selected==true) {
			var rowFound=false;
			var existingObj=null;
			for (j=0;j<destObj.length;j++) {
				if (destObj.options[j].value==srcObj.options[i].value) {
                    srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,               
					rowFound=true
					existingObj=destObj.options[j]
					break
				}
			}
			if (rowFound!=true) {
				var newColObj=document.createElement("OPTION")
				newColObj.value=srcObj.options[i].value
                if (browser_ie) 
                    newColObj.innerText=srcObj.options[i].innerText
				else if (browser_nn4 || browser_nn6) 
                    newColObj.text=srcObj.options[i].text
				destObj.appendChild(newColObj)//右键
				srcObj.options[i].selected=false
                srcObj.options.remove(i);
                i=-1;
				newColObj.selected=true
				rowFound=false
			} else {
				if(existingObj != null) 
                    existingObj.selected=true
			}
		}
	}
}

/**
 *@edit:andy 
 *@date:
 *@reason:左右结构点击事件
 *@version:
 */
function addColumn(source, destination) 
{
    var availListObj=getObj(source)
    var selectedColumnsObj=getObj(destination)


    for (i=0;i<availListObj.length;i++) 
    {
        if (availListObj.options[i].selected==true) 
        {            	
        	var rowFound=false;
        	var existingObj=null;
            for (j=0;j<selectedColumnsObj.length;j++) 
            {
                if (selectedColumnsObj.options[j].value==availListObj.options[i].value) 
                {
                    rowFound=true
                    existingObj=selectedColumnsObj.options[j]
                    break
                }
            }
            if (rowFound!=true) 
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=availListObj.options[i].value
                if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                selectedColumnsObj.appendChild(newColObj)
                availListObj.options[i].selected=false
                newColObj.selected=true
                availListObj.remove(i);//20140902，diony，右移时删除左边信息
                rowFound=false
            } 
            else 
            {
                if(existingObj != null) existingObj.selected=true
            }
        }
    }
}
