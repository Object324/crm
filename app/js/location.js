var map ='';
var androidtimeoutid;
//异步加载百度地图js
function loadLocationJScript(){
    var x = 0,y = 0;
    if(phoneversion == 'ios'){//IOS定位
        getLocationbyIOS();//调用获取IOS经纬度
    }
    else if(phoneversion == 'android'){//android定位
        javatojs.InitLocation();  
        androidtimeoutid=setInterval("getAndroidLoction()",100);//每隔100毫秒读取经度纬度
    }
    else{
        theLocation(121.48778141583,31.231436137866,5000,12);//外勤签到
        //theLocationIOSCrm(121.48778141583,31.231436137866,5000,12);//附近客户
        //theLocationIOSWork(121.48778141583,31.231436137866);//工作定位
    }
}
//每隔100毫秒读取经度纬度
function getAndroidLoction(){
    var strlocation=javatojs.getLocation();
    if(strlocation!=""){
        clearInterval(androidtimeoutid);
        var locs=strlocation.split(",");
        theLocation(locs[0],locs[1]);
    }
}
//获取IOS经纬度
function getLocationbyIOS(){
    navigator.geolocation.getCurrentPosition(onSuccessLocation, onErrorLocation, { maximumAge: 3000, timeout: 20000, enableHighAccuracy: true });
}
//IOS定位成功
var onSuccessLocation = function(position) {
    var positionlog = position.coords.longitude,
        positionlat = position.coords.latitude;
    if(category=='work'){//工作-发微博等-定位
        theLocationIOSWork(positionlog,positionlat);    
    }
    else if(category=='crm'){
        if(category_for==='crm'){//CRM-附近客户
            theLocationIOSCrm(positionlog,positionlat,5000,12);
        }
        else if(category_for==='apply'){//应用-外勤签到
            theLocationIOSApply(positionlog,positionlat);
        }        
    }
};
//失败
function onErrorLocation(error){
    PopPromptBox.show('定位失败');
    return false;
}
//IOS定位：工作-发微博等-定位
function theLocationIOSWork(longitude,latitude){
    // 百度地图API功能    
    map = new BMap.Map("allmap");
    var new_point = new BMap.Point(longitude,latitude);
    map.centerAndZoom(new_point,15);
    map.enableScrollWheelZoom(true);
    map.clearOverlays();
    
    var point = longitude+','+latitude;
    var AjaxUrl = 'http://api.map.baidu.com/geoconv/v1/?coords='+point+'&from=1&to=5&ak=Hgvb6X18khZw223dBW1hFHuT';
    ld.ajax({
        type: "get",
        contentType: "application/json; charset=utf-8",
        dataType: "jsonp",
        url: AjaxUrl,  //这里是网址
        success: function (data) {
            var new_point = new BMap.Point(data.result[0].x,data.result[0].y);
            var marker = new BMap.Marker(new_point);
            map.addOverlay(marker);
            //var label = new BMap.Label("我是百度标注哦",{offset:new BMap.Size(20,-10)});
            //marker.setLabel(label); //添加百度label
            map.setCenter(new_point);
            //new_point = new BMap.Point(point.lng,point.lat);
            var marker = new BMap.Marker(new_point);
            map.addOverlay(marker);
            var geoc = new BMap.Geocoder();
            geoc.getLocation(new_point, function(rs){
                var addComp = rs.addressComponents;
                var address = '';
                var str=data.result[0].x+","+data.result[0].y;
                if( addComp.province=='上海市'||addComp.province=='北京市' || 
                    addComp.province=='天津市'||addComp.province=='重庆市'){
                    var district = addComp.district;
                    if(district == '闸北区'){
                        district = '静安区';
                    }
                    address = addComp.city + district + addComp.street + addComp.streetNumber;
                }
                else{
                    address = addComp.province + addComp.city + addComp.district + addComp.street + addComp.streetNumber;
                }
                ld('#sign_address_work').html('<span>'+address+'</span><i class="lnr-chevron-right"></i>');
                ld('.positionAddress').html(address);
                ld('.positionAddressXY').html(str);
            });
        },
        timeout: 20000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
        }
    });
}
//IOS定位：应用-外勤签到
function theLocationIOSApply(longitude,latitude){
    
    var point = longitude+','+latitude;
    var AjaxUrl = 'http://api.map.baidu.com/geoconv/v1/?coords='+point+'&from=1&to=5&ak=Hgvb6X18khZw223dBW1hFHuT';
    ld.ajax({
        type: "get",
        contentType: "application/json; charset=utf-8",
        dataType: "jsonp",
        url: AjaxUrl,  //这里是网址
        success: function (data) {
            var new_point = new BMap.Point(data.result[0].x,data.result[0].y);
            var geoc = new BMap.Geocoder();
            geoc.getLocation(new_point, function(rs){
                var addComp = rs.addressComponents;
                var address = '';
                var str=data.result[0].x+","+data.result[0].y;
                if( addComp.province=='上海市'||addComp.province=='北京市' ||
                    addComp.province=='天津市'||addComp.province=='重庆市')
                {
                    var district = addComp.district;
                    if(district == '闸北区'){
                        district = '静安区';
                    }
                    address = addComp.city + district + addComp.street + addComp.streetNumber;
                }
                else{
                    address = addComp.province + addComp.city + addComp.district + addComp.street + addComp.streetNumber;
                }
                ld('#sign_address_crm').html(address);
                ld('.positionAddressXY').html(str);
            });
        },
        timeout: 20000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
        }
    });
}

//安卓定位
var maplongitude,maplatitude;
function theLocation(longitude,latitude){ 
    if(category=='work'){//IOS定位：工作-发微博等-定位
        var script = document.createElement("script");
    	script.type = "text/javascript";
    	script.src = "http://api.map.baidu.com/api?v=2.0&ak=Hgvb6X18khZw223dBW1hFHuT&callback=androidInit";
    	document.body.appendChild(script);
        maplatitude=latitude;
        maplongitude=longitude;     
        //map.panTo(new_point);   
    }
    else if(category=='crm'){
        if(category_for==='crm'){//CRM-附近客户
            theLocationIOSCrm(longitude,latitude,5000,12);
        }
        else if(category_for==='apply'){//应用-外勤签到
            var new_point = new BMap.Point(longitude,latitude);
            var geoc = new BMap.Geocoder();   
            geoc.getLocation(new_point, function(rs){    
                var addComp = rs.addressComponents;
                var str=longitude+","+latitude;
                if(addComp.province=='上海市'||addComp.province=='北京市' || 
                addComp.province=='天津市'||addComp.province=='重庆市'){
                    var district = addComp.district;
                    if(district == '闸北区'){
                        district = '静安区';
                    }
                    address = addComp.city + district + addComp.street + addComp.streetNumber;
                }
                else{
                    address = addComp.province + addComp.city + addComp.district + addComp.street + addComp.streetNumber;
                }
                //ld('#sign_address_crm').parent().parent().addClass('lnr-chevron-right');
                ld('#sign_address_crm').html(address);
                ld('.positionAddressXY').html(str);
            });
        }             
    }        
}
//安卓定位
function androidInit(){
    map = new BMap.Map("allmap");
    var new_point = new BMap.Point(maplongitude,maplatitude);
    map.centerAndZoom(new_point,15);
    //map.enableScrollWheelZoom(true);
    map.clearOverlays(); 
    var marker = new BMap.Marker(new_point); 
    map.addOverlay(marker);  
    var new_point = new BMap.Point(maplongitude,maplatitude);
    var geoc = new BMap.Geocoder();   
    geoc.getLocation(new_point, function(rs){
        var addComp = rs.addressComponents;
        var str=maplongitude+","+maplatitude;
        if(addComp.province=='上海市'||addComp.province=='北京市' || 
        addComp.province=='天津市'||addComp.province=='重庆市'){
            address = addComp.city + addComp.district + addComp.street + addComp.streetNumber;
        }
        else{
            address = addComp.province + addComp.city + addComp.district + addComp.street + addComp.streetNumber;
        }
        ld('#sign_address_work').html('<span>'+address+'</span><i class="lnr-chevron-right"></i>');
        ld('.positionAddress').html(address);
        ld('.positionAddressXY').html(str);
    });
}
//定位：CRM-附近客户—定位传值
function theLocationIOSCrm(longitude,latitude,distance,pointvalue){
    ViewObj.rootScope.nearbylongitude = longitude;
    ViewObj.rootScope.nearbylatitude = latitude;
    ViewObj.rootScope.nearbydistance = distance;
    ViewObj.rootScope.nearbypointvalue = pointvalue;
    map = new BMap.Map("container");
    var mPoint = new BMap.Point(longitude,latitude);
    map.centerAndZoom(mPoint, pointvalue);
    map.enableScrollWheelZoom();        //启用滚轮缩放

    // 销毁 地图周边 滚动对象
    if(SwiperObj.isDestroyable(SwiperObj.maparound_swiper)){
        try{
            SwiperObj.maparound_swiper.destroy(true,true);
        }catch(e){}
    }
    if(phoneversion == 'ios'){//IOS定位
        /*
        //坐标转换完之后的回调函数
        translateCallback = function (point){
            mPoint = new BMap.Point(point.lng,point.lat);
            var marker = new BMap.Marker(mPoint);
            var circle = new BMap.Circle(point,distance,{ 
                strokeColor:"blue", //圆形边线颜色 
                fillColor:"blue", //圆形填充颜色。当参数为空时，圆形将没有填充效果 
                strokeWeight: 1,     //圆形边线的宽度，以像素为单位 
                fillOpacity: 0.1,    //圆形填充的透明度，取值范围0 - 1 
                strokeOpacity:0.3,   //圆形边线透明度，取值范围0 - 1 
                strokeStyle:"solid",    //圆形边线的样式，solid或dashed 
                enableMassClear:true,   //是否在调用map.clearOverlays清除此覆盖物，默认为true 
                enableEditing:false,    //是否启用线编辑，默认为false 
                enableClicking:true  //是否响应点击事件，默认为true 
            });
            map.addOverlay(marker);
            map.setCenter(point);
            map.addOverlay(circle); //增加圆
            ViewObj.rootScope.nearbylongitude = point.lng;
            ViewObj.rootScope.nearbylatitude = point.lat;
            //加载附近客户
            loadNearbyAccounts(point.lng,point.lat,distance);
        }
        setTimeout(function(){
            BMap.Convertor.translate(mPoint,0,translateCallback);     //真实经纬度转成百度坐标
        }, 2000);
        */
        var point = longitude+','+latitude;
        var AjaxUrl = 'http://api.map.baidu.com/geoconv/v1/?coords='+point+'&from=1&to=5&ak=Hgvb6X18khZw223dBW1hFHuT';
        ld.ajax({
            type: "get",
            contentType: "application/json; charset=utf-8",
            dataType: "jsonp",
            url: AjaxUrl,  //这里是网址
            success: function (data) {
                mPoint = new BMap.Point(data.result[0].x,data.result[0].y);
                var marker = new BMap.Marker(mPoint);
                var circle = new BMap.Circle(mPoint,distance,{ 
                    strokeColor:"blue", //圆形边线颜色 
                    fillColor:"blue", //圆形填充颜色。当参数为空时，圆形将没有填充效果 
                    strokeWeight: 1,     //圆形边线的宽度，以像素为单位 
                    fillOpacity: 0.1,    //圆形填充的透明度，取值范围0 - 1 
                    strokeOpacity:0.3,   //圆形边线透明度，取值范围0 - 1 
                    strokeStyle:"solid",    //圆形边线的样式，solid或dashed 
                    enableMassClear:true,   //是否在调用map.clearOverlays清除此覆盖物，默认为true 
                    enableEditing:false,    //是否启用线编辑，默认为false 
                    enableClicking:true  //是否响应点击事件，默认为true 
                });
                map.addOverlay(marker);
                map.setCenter(mPoint);
                map.addOverlay(circle); //增加圆
                //加载附近客户
                loadNearbyAccounts(data.result[0].x,data.result[0].y,distance);
            },
            timeout: 20000,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
            }
        });
    }
    else{
        map.addEventListener("tilesloaded",function(){
            var circle = new BMap.Circle(mPoint,distance,{ 
                strokeColor:"blue", //圆形边线颜色 
                fillColor:"blue", //圆形填充颜色。当参数为空时，圆形将没有填充效果 
                strokeWeight: 1,     //圆形边线的宽度，以像素为单位 
                fillOpacity: 0.1,    //圆形填充的透明度，取值范围0 - 1 
                strokeOpacity:0.3,   //圆形边线透明度，取值范围0 - 1 
                strokeStyle:"solid",    //圆形边线的样式，solid或dashed 
                enableMassClear:true,   //是否在调用map.clearOverlays清除此覆盖物，默认为true 
                enableEditing:false,    //是否启用线编辑，默认为false 
                enableClicking:true  //是否响应点击事件，默认为true 
            });
            map.clearOverlays();
            map.addOverlay(new BMap.Marker(mPoint)); //,{icon:myIcon}
            map.addOverlay(circle); //增加圆
        });
        //加载附近客户
        loadNearbyAccounts(longitude,latitude,distance);
    }
}
//加载附近客户
function loadNearbyAccounts(longitude,latitude,distance){
    var urlstring = 'module=Accounts&action=NearbyAccounts&distance='+distance+
                    '&cuurlongitude='+longitude+'&cuurlatitude='+latitude+
                    '&page=1&searchcontent=&orderby=asc';
    WordReportAjax(urlstring,function(rest){      
        if(empty(rest)) return false;
        var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);  
        var mapAroundlist='<div style="wdith:100%;height:0.5rem;"></div><div id="mapAroundlist" class="pubclear nearby"><div class="swiper-container map-around"><ul class="swiper-wrapper crm-lists nearby">';
        if(empty(restobj.result.list1)){
            mapAroundlist='<div class="tip">没有客户信息</div>';
        }
        else{
            ld.each(restobj.result.list1,function(key,list){
                mapAroundlist +='<li record="'+list.accountid+'" class="swiper-slide lnr-chevron-right">'+
                                '<h5 class="text-ellipsis" tag="0">'+list.accountname+'</h5><p>'+
                                '<span class="text-ellipsis">距您'+list.juli+'米&nbsp;&nbsp;'+
                                list.address+'</span></p></li>';
            });
        }
        mapAroundlist+='<div class="swiper-slide" style="border:0px;"></div>';
        mapAroundlist+='</ul></div></div>';
        ld('#panel').html(mapAroundlist);
        //给地图周边添加滚动
        var mapAroundlist_height=SwiperObj.homePage_swiper.height-ld('#container').height();
        ld('#mapAroundlist .swiper-container').height(mapAroundlist_height); // 设置列表高度
        ld('#mapAroundlist .swiper-slide').height('60px'); // 设置 每一列 高度
        // 创建地图周边 滚动 对象
        SwiperObj.maparound_swiper = new Swiper('.swiper-container.map-around',{
            loop:false,
            direction: 'vertical',
            slidesPerView: 'auto',
            freeMode: true
        });
        //SwiperObj.is_currentViewRefreshable = true;
        ld('#mapAroundlist p').css('marginTop','3px'); // 设置 列表内容竖直 居中
    });
}

//安卓签到打开GPS
function openGPS(){
    javatojs.openGPS();
}

//外勤签到，地址打开地图
function mapSetPosition(){
    var point = ld('.positionAddressXY').html();
    var pointarr =point.split(",");
    var signlongtitude = pointarr[0],
        signlatitude = pointarr[1];
    var map = new BMap.Map("container");
    var mPoint = new BMap.Point(signlongtitude,signlatitude);
    // 打包前 注释下面一句话
    //var mPoint = new BMap.Point(121.48778141583,31.231436137866);
    map.centerAndZoom(mPoint, 15);
    map.enableScrollWheelZoom();        //启用滚轮缩放
    var mOption = {
        poiRadius : 500,            //默认100米
        numPois : 10                //默认10个
    }
    
    var myGeo = new BMap.Geocoder();        //创建地址解析实例
    //map.addOverlay(new BMap.Circle(mPoint,500));        //添加一个圆形覆盖物
    map.addEventListener("tilesloaded",function(){
        map.clearOverlays();
        map.addOverlay(new BMap.Marker(mPoint)); //,{icon:myIcon}
    });
    myGeo.getLocation(mPoint,
        function mCallback(rs){
            // 销毁  地图周边 滚动对象
            if(SwiperObj.isDestroyable(SwiperObj.maparound_swiper)){
                try{
                    SwiperObj.maparound_swiper.destroy(true,true);
                }catch(e){}
            }
            var allPois = rs.surroundingPois;       //获取全部POI（该点半径为100米内有6个POI点）
            var mapAroundlist='<div style="wdith:100%;height:0.5rem;"></div><div id="mapAroundlist" class="signaround"><div class="swiper-container map-around"><div class="swiper-wrapper">';
            for(i=0;i<allPois.length;++i){
                mapAroundlist+='<div class="swiper-slide"><p class="lnr-circle"><i class="text-ellipsis" lng="'+allPois[i].point['lng']+'" lat="'+allPois[i].point['lat']+'">'+ allPois[i].title+'</i><span class="text-ellipsis">' + allPois[i].address+ '</span></p></div>';
                map.addOverlay(new BMap.Marker(allPois[i].point));
            }
            mapAroundlist+='<div class="swiper-slide" style="border:0px;"></div>';
            mapAroundlist+='</div></div></div>';
            ld('#panel').html(mapAroundlist);
            //给地图周边添加滚动
            var mapAroundlist_height=SwiperObj.homePage_swiper.height-ld('#container').height();
            ld('#mapAroundlist .swiper-container').height(mapAroundlist_height); // 设置列表高度
            ld('#mapAroundlist .swiper-slide').height('60px'); // 设置 每一列 高度
            // 创建地图周边 滚动 对象
            SwiperObj.maparound_swiper = new Swiper('.swiper-container.map-around',{
                loop:false,
                direction: 'vertical',
                slidesPerView: 'auto',
                freeMode: true
            });
            ld('#mapAroundlist p').css('marginTop','3px'); // 设置 列表内容竖直 居中
    },mOption);        
}

//工作签到，打开周边位置
function workMorePosition(point){
    var pointarr =point.split(",");
    var mPoint = new BMap.Point(pointarr[0],pointarr[1]);
    var myGeo = new BMap.Geocoder();        //创建地址解析实例
    var mOption = {
        poiRadius : 500,            //默认100米
        numPois : 10                //默认10个
    }
    myGeo.getLocation(mPoint,
        function mCallback(rs){
            var allPois = rs.surroundingPois;       //获取全部POI（该点半径为100米内有6个POI点）
            var mapAroundlist='<ul class="crm-lists">';
            for(i=0;i<allPois.length;++i){
                mapAroundlist+='<li lng="'+allPois[i].point['lng']+'" lat="'+allPois[i].point['lat']+'">'+
                               '    <h5>'+ allPois[i].title+'</h5>'+
                               '    <p>'+
                               '    <span>' + allPois[i].address+ '</span>'+
                               '    </p>'+
                               '</li>';
            }
            mapAroundlist+='</ul>';            
            ld('#work-positionmore-view').html(mapAroundlist);            
    },mOption);        
}