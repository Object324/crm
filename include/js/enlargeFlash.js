/**
 *@edit:andy 
 *@date:
 *@reason:0011562: 首页界面：销售漏斗、最近六个月销售情况、签约额月度同比组件，点击放大按钮放大的弹出层中，1.增加组件名称，2.弹出层样式还是老的样式
 *@version:
 */
function sAlert(flashID,flashTitle){
//function sAlert(flashID){
//var flashID="stuffcont_"+ID;
//alert(flashTitle)

var msgw,msgh,bordercolor;
msgw=600;//提示窗口的宽度
msgh=400;//提示窗口的高度
titleheight=25; //提示窗口标题高度
bordercolor="#336699";//提示窗口的边框颜色
titlecolor="#99CCFF";//提示窗口的标题颜色
var sWidth,sHeight;
var topScroll=document.documentElement.scrollTop;
sWidth=document.body.offsetWidth;
sHeight=document.body.offsetHeight;
var bgObj=document.createElement("div");
bgObj.setAttribute('id','bgDiv');
bgObj.style.position="absolute";
bgObj.style.top="0";
bgObj.style.background="#777";
bgObj.style.filter="PRogid:DXImageTransform.Microsoft.Alpha(style=3,opacity=25,finishOpacity=75";
bgObj.style.opacity="0.6";
bgObj.style.left="0";
bgObj.style.width=sWidth + "px";
bgObj.style.height=sHeight + "px";
bgObj.style.zIndex = "10000";
document.body.appendChild(bgObj);
var msgObj=document.createElement("div")
msgObj.setAttribute("id","msgDiv");
msgObj.setAttribute("class","D_pop_box");//andy
msgObj.setAttribute("align","center");
msgObj.style.background="white";
//msgObj.style.border="1px solid " + bordercolor;//边框
msgObj.style.position = "absolute";
msgObj.style.left = "40%";
msgObj.style.top = "30%";
msgObj.style.font="12px/1.6em Verdana, Geneva, Arial, Helvetica, sans-serif";
//msgObj.style.marginLeft = "-225px" ;
msgObj.style.marginLeft = -200+document.documentElement.scrollLeft+"px" ;
//标准浏览器只识别document.documentElement.scrollTop，不识别document.body.scrollTop
//谷歌浏览器只识别document.body.scrollTop，而不识别document.documentElement.scrollTop
msgObj.style.marginTop = -75+document.documentElement.scrollTop+document.body.scrollTop+"px" ;
msgObj.style.width = msgw + "px";
msgObj.style.height =msgh + "px";
msgObj.style.textAlign = "center";
msgObj.style.lineHeight ="25px";
msgObj.style.zIndex = "10001";
var title=document.createElement("div");
title.setAttribute("id","msgTitle");
title.setAttribute("class","D_pop_tit");//andy border-bottom: medium none;
//title.setAttribute("align","left");
title.style.margin="-2px";
title.style.padding="3px";
//title.style.background=bordercolor;//#7eb2d4 
//iamgeurl="url('themes/icon/pop_close.png' )";
//title.style.background=bordercolor;
title.style.filter="progid:DXImageTransform.Microsoft.Alpha(startX=20, startY=20, finishX=100, finishY=100,style=1,opacity=75,finishOpacity=100);";
title.style.opacity="1";
//title.style.border="1px solid " + bordercolor;//ANDY
title.style.borderBottom="medium none";
title.style.height="32px";//andy
title.style.font="12px Verdana, Geneva, Arial, Helvetica, sans-serif";
title.style.color="white";

var strong=document.createElement("strong");//andy
strong.setAttribute("class","D_ptita");//andy
strong.innerHTML=flashTitle;//关闭按钮
strong.style.lineHeight="25px";

var href=document.createElement("a");
href.setAttribute("class","D_ptitc");//andy
href.href="javascript:;";
href.setAttribute("id","myhref");
href.style.marginTop="0";


var imagetwo=document.createElement("img");
imagetwo.src="themes/icon/pop_close.png";//关闭按钮
imagetwo.setAttribute("class","D_ptitcimg");//andy
imagetwo.style.marginLeft="0";

var cancel=document.createElement("img");
cancel.src="themes/images/closewhite.gif";//关闭按钮
cancel.style.cursor="pointer";
cancel.style.padding="3px 0 10px 0";
href.onclick=function(){
//document.getElementById("msgDiv").removeChild(title);
//document.getElementById("msgDiv").removeChild(txt);
document.body.removeChild(bgObj);
document.body.removeChild(msgObj);
}
document.body.appendChild(msgObj);
document.getElementById("msgDiv").appendChild(title);
document.getElementById("msgTitle").appendChild(strong);//andy
document.getElementById("msgTitle").appendChild(href);//andy
document.getElementById("myhref").appendChild(imagetwo);

var txt=document.createElement("div");
txt.style.margin="1em 0"
txt.setAttribute("id","msgTxt");
txt.style.height="320px";
txt.innerHTML=flashID.innerHTML;//添加FLASH

/**
 * 对IE浏览器特别处理，FireFox、Chrome、Opera处理方式一样
 * @reason 0010439 IE9浏览器：首页，点击组件上面的 “放大镜”按钮，放大后的flash组件显示为空白
 * @author Tujt 2014-09-25
 */
var os = getbrowser();
if(os != ''){
	switch(os){//浏览器兼容
		case 'MSIE':
			try{
				for(var i=0;;i++){//查找OBJECT节点
					if(txt.childNodes[i].tagName=='OBJECT'){
						txt.childNodes[i].style.width="100%";
						txt.childNodes[i].style.height="100%";
						txt.childNodes[i].play();
						break;
					}
				}
			}catch(e){//IE适用
				txt.getElementsByTagName("embed")[0].style.width="100%";
				txt.getElementsByTagName("embed")[0].style.height="100%";
			}
			break;
		default://FireFox、Chrome、Opera 测试通过
			try{
				txt.getElementsByTagName("embed")[0].style.width="100%";
				txt.getElementsByTagName("embed")[0].style.height="100%";
			}catch(e){//IE适用
				for(var i=0;;i++){//查找OBJECT节点
					if(txt.childNodes[i].tagName=='OBJECT'){
						txt.childNodes[i].style.width="100%";
						txt.childNodes[i].style.height="100%";
						txt.childNodes[i].play();
						break;
					}
				}
			}
			break;
	}
}
//try//FireFox适用
//{
	//txt.getElementsByTagName("embed")[0].style.width="100%";
	//txt.getElementsByTagName("embed")[0].style.height="100%";
//}
//catch(e)//IE适用
//{
    //for(var i=0;;i++)//查找OBJECT节点
    //{
        //if(txt.childNodes[i].tagName=='OBJECT')
        //{
        //txt.childNodes[i].style.width="100%";
        //txt.childNodes[i].style.height="100%";
        //txt.childNodes[i].play();
        //break;
        //};
    //}
//}
document.getElementById("msgDiv").appendChild(txt);


}
/**
 * 获取当前浏览器类型
 * @reason 0010439 IE9浏览器：首页，点击组件上面的 “放大镜”按钮，放大后的flash组件显示为空白
 * @author Tujt 2014-09-25
 */
var getbrowser = function(){//获取当前浏览器类型
	if(navigator.userAgent.indexOf('MSIE')>0) {
		return 'MSIE';
	}else if(navigator.userAgent.indexOf('Firefox') > 0){
		return 'Firefox';
	}else if(navigator.userAgent.indexOf('Chrome') > 0){
		return 'Google';
	}else if(navigator.userAgent.indexOf('Opera') > -1){
		return 'Opera';
	}else if(navigator.userAgent.indexOf('Safari') > 0){
		return 'Safari';
	}else{
		return '';
	}
}
