<script>
var tmpstr='{$DATETIMESTR}';
var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
</script>
 {include file='newAdvanceFilter.tpl'}
