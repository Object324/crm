function TrackLocationMap()
{

}

TrackLocationMap.getDate=function(date)
{
    var yyyy = date.getFullYear();
    var mm = String(date.getMonth() + 1).padStart(2, '0'); // January is 0!
    var dd = String(date.getDate()).padStart(2, '0');
    return yyyy + '-' + mm + '-' + dd;
}
TrackLocationMap.changeday=function(changetype)
{
         var datevalue=ld(" input[name=trackmapdate]").val();


         if(changetype=='prev')
         {
             const yesterday = new Date(datevalue);
             yesterday.setDate(yesterday.getDate() - 1);


             ld(" input[name=trackmapdate]").val(TrackLocationMap.getDate(yesterday))
         }
         else{
                //后一天
             const tomorrow = new Date(datevalue);
             tomorrow.setDate(tomorrow.getDate() + 1);

             ld(" input[name=trackmapdate]").val(TrackLocationMap.getDate(tomorrow))
         }
         TrackLocationMap.searchdate=ld(" input[name=trackmapdate]").val();
         TrackLocationMap.DateChange();
}
TrackLocationMap.DateChange=function ()
{
    TrackLocationMap.searchdate=ld(" input[name=trackmapdate]").val();
    var choosedate = new Date(TrackLocationMap.searchdate + ' 23:59:59 ');
    var now_date = new Date();
    if(now_date > choosedate){
        ld('#choosedate_next').show();
    }else{
        ld('#choosedate_next').hide();
    }
    TrackLocationMap.search();
}

var mapPositionobj;//定义地图对象
TrackLocationMap.changeMap=function(maptype,userid){
    if(maptype != TrackLocationMap.maptype){
        TrackLocationMap.maptype=maptype;
        var btn_track = ld('#mapshowtrack');
        var btn_position = ld('#mapshowposition');
        var date_obj = ld('#mapsearchdate');
        if(maptype == 'showtrack'){
            if(userid >0){
                TrackLocationMap.userid = userid;
            }
            btn_track.addClass('track_select');
            btn_position.removeClass('track_select');
            date_obj.css('display','flex');
        }else{
            btn_position.addClass('track_select');
            btn_track.removeClass('track_select');
            date_obj.css('display','none');
        }
        TrackLocationMap.search();
    }
}
TrackLocationMap.search=function()
{
    var trackpositionobj=TrackPosition.getInstance();
    trackpositionobj.init('TrackLocationContainer');
    trackpositionobj.clearmap();
    ldAjax("index.php?module=TrackLocationMap&action=TrackLocationMapAjax&file=index&maptype="+TrackLocationMap.maptype+"&ajax=yes&userid="+TrackLocationMap.userid+"&searchdate="+TrackLocationMap.searchdate,{},function(ajaxdata){


        if(TrackLocationMap.maptype=='showposition')
        {
            //listcontentobj.html(ajaxdata.result.content);
            //initShowPositionMap('LocationPositionMap',ajaxdata.result.info);
            trackpositionobj.drawpoint(ajaxdata.result.list);
        }
        else{

            trackpositionobj.draw(ajaxdata.result.list);
        }
        EmptyProgressObjs();


    })

}
// 重置地图内容
TrackLocationMap.reset=function()
{
    ldAjax("index.php?module=TrackLocationMap&action=TrackLocationMapAjax&file=index&maptype="+TrackLocationMap.maptype+"&resetmap=yes&userid="+TrackLocationMap.userid+"&searchdate="+TrackLocationMap.searchdate,{},function(ajaxdata){


        if(TrackLocationMap.maptype=='showposition')
        {
            listcontentobj.html(ajaxdata.result.content);
            initShowPositionMap('LocationPositionMap',ajaxdata.result.info);
        }
        else{
            listcontentobj.html(ajaxdata.result.content);
            var trackpositionobj=TrackPosition.getInstance();
            trackpositionobj.init('TrackLocationContainer');
            trackpositionobj.draw(ajaxdata.result.list);
        }
        EmptyProgressObjs();


    })

}

TrackLocationMap.listtrack = function() {
    window.open('index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=listtracks');
}
