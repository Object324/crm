 var objoa;//34829: 加班单、请假单查看明细界面-更多-考勤统计：勾选/反选复选框“只统计已审批通过的单据 ”时应该触发重算
function JSOA(module,record)
{
    this.module=module;
    this.record=record;
    
}
JSOA.prototype.setSmownerId=function(smownerid)
{
    this.smownerid=smownerid
}
/**
*考勤统计
*
*/
JSOA.prototype.showAttencePop=function(obj)
{
   var queryapproved='no';
   /*if(obj.type!=undefined&&obj.type.toLowerCase()=='checkbox')
   {
         if(obj.checked)
         {
            queryapproved='no';
         }
         else
         {
            queryapproved='yes';
         }
   }
   else*/ if(document.getElementById('oachkAttendance').checked)
   {
        queryapproved='yes';
   }
  
    ld.ajax({
          type:"POST",
          url:'index.php?module='+this.module+"&id="+this.record+"&action="+this.module+'Ajax&file=Attendance&queryapprove='+queryapproved+'&ajax=true',
          datatype:"json",
          success:function(data)
          {
                data=eval('('+ data+')')?eval('('+ data +')'):JSON.parse(data);
                document.getElementById('oatotalovertimetd').innerHTML=data.oatotalovertime;
                document.getElementById('oatotaldaysofftd').innerHTML=data.oatotaldaysoff;
                document.getElementById('oaremainingovertimetd').innerHTML=data.oaremainingovertime;
                document.getElementById('oatotalannualleavetd').innerHTML=data.oatotalannualleave;
                document.getElementById('oausedannualleavetd').innerHTML=data.oausedannualleave;
                document.getElementById('oaremainingannualleavetd').innerHTML=data.oaremainingannualleave;
                /*if(data.isviewdetail=='yes')
                {
                    document.getElementById('oaviewdetailattendance').style.display='';
                }
                else
                {
                    document.getElementById('oaviewdetailattendance').style.display='none';
                }*/
                 // fnvshobj(obj, 'oashowAttendance');
          }
    });
     
        
}


 function showAttencePop(module, record){
     //初始化未加载弹框时默认为勾选 queryapprove=yes
     var urlstring = 'index.php?module='+module+"&id="+record+"&action="+module+'Ajax&file=Attendance&queryapprove=yes';
     ldAjax(urlstring,"",function(data){
         var crmPopupobj=CrmPopup.load(data.result.title,"","","LdPopWidth400px",'Settings',"","","","");
         crmPopupobj.prevshow();
         crmPopupobj.show(data.result.content);
         DelProgressObjs();
     });
     return false;

 }