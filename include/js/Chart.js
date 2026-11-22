/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
 var httpreq=null;
          function sethiddenValue(hiddenvalue)
          {
             document.getElementById("chartxml").innerHTML=hiddenvalue;
          }
           
            function ajaxchart(urlparam)
            {
                  httpreq=createXMLHTTP();
                  httpreq.open("POST",urlparam,true);
                  httpreq.onreadystatechange=SessionRequest;
                  httpreq.setRequestHeader("If-Modified-Since","0");
                  httpreq.send();
            }
            function SessionRequest()
            {
                if(httpreq.readyState==4)
                {
                         if(httpreq.status==0||httpreq.status==200)
                         {
                            
                            if(document.getElementById("chartxml")!=undefined)
                            
                            {
                                chartRedraw(httpreq.responseText,document.getElementById("chartxml").innerHTML);
                            }
                            else 
                            {
                                chartRedraw(httpreq.responseText,"");
                            }
                              
                        }
                }
            }
            //绘制图形化报表
   
     function chartRedraw(swfFileName,strGraph)
     {
      
        if(document.getElementById("chartxml")==undefined)
        {
            document.getElementById("chartdiv").style.width="900px";
            document.getElementById("chartdiv").style.height="500px";
            document.getElementById("chartdiv").style.lineHeight="500px";
            document.getElementById("chartdiv").align="center";
            document.getElementById("chartdiv").style.color="#333";
            document.getElementById("chartdiv").innerHTML="无数据显示";
            return ;
        }
         var filename="FCF_"+swfFileName+".swf";
          document.getElementById("chartdiv").align="left";
         if(document.getElementById('MultiSerials').value=='1')
         {
            filename="FCF_MS"+swfFileName+".swf";
         }
        
         while(strGraph.indexOf("||N||")!=-1)
         {
           strGraph= strGraph.replace("||N||","'");
         }
         while(strGraph.indexOf("||M||")!=-1)
         {
            strGraph= strGraph.replace("||M||","<");
         }
           while(strGraph.indexOf("||V||")!=-1)
         {
            strGraph= strGraph.replace("||V||",">");
         }
        // strGraph="<?xml version='1.0' encoding='UTF-8' ?> "+strGraph;

        if(document.getElementById("myChartId")!=undefined)
        {
           document.getElementById("chartdiv").innerHTML="";        
        }
        document.getElementById("chartname").value=document.getElementById("chartname").value+1;
        var myChart = new FusionCharts("include/FusionCharts/"+filename, "myChartId"+document.getElementById("chartname").value, "900", "500");               
         myChart.setDataXML(strGraph);
         myChart.render("chartdiv");
     }