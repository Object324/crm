

function getRequester()
{
  try
  {
      if(window.XMLHttpRequest) 
      {
          return new XMLHttpRequest();
      } 
      else if(window.ActiveXObject)
      {
         try 
         {
               return new ActiveXObject("Microsoft.XMLHTTP");
         } catch (e) 
         {
               try {
                    return new ActiveXObject("Msxml2.XMLHTTP");
               } catch (e) {return false;}
         }          
      }
  }
  catch (e) 
  {
      return false;
      //alert("You need a browser which supports an XMLHttpRequest Object.\nMozilla build 0.9.5 has this Object and IE5 and above.");
  }
}

/*
onreadystatechange	Event handler for an event that fires at every state change
readyState	Object status integer:
0 = uninitialized
1 = loading
2 = loaded
3 = interactive
4 = complete
responseText	String version of data returned from server process
responseXML	DOM-compatible document object of data returned from server process
status	Numeric code returned by server, such as 404 for "Not Found" or 200 for "OK"
statusText	String message accompanying the status code
*/
function lingdangAjax(cb)
{
  var me = this;
  this.requester = getRequester();
  
  if(cb)
    this.callback = cb;
  else
    this.callback = function(req)
    {
      return eval(req.responseText);
    }

  this.requester.onreadystatechange = function(){
    switch(me.requester.readyState)
    {
      case 1:
      case 2:
      case 3:
        break;
      case 4:
        var response = me.callback(me.requester);
        break;
      default:
        alert("Error");
        break;
    }
  }

  this.state = function()
  {
    return me.requester.readyState;
  }

  this.process = function(url, parameters){
    me.requester.open("POST", url, true);
    me.requester.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    me.requester.setRequestHeader("Content-length", parameters.length);
    me.requester.setRequestHeader("Connection", "close");
    me.requester.send(parameters);
  }
}


function createXMLHTTP()
     {
        var request;
        var browser=navigator.appName;
     
        if(browser=="Microsoft Internet Explorer")
        {
            var arrVersions=["MSXML2.XMLHttp.5.0","MSXML2.XMLHTTP.4.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"];
            for( var i=0;i<arrVersions.length;i++)
            {
                try
                {
                     request=new ActiveXObject(arrVersions[i]);
                    return request;
                }
                catch(exception)
                {
                }
            }
        }
        else 
        {
          request=new XMLHttpRequest();
          return request;
        }
}



