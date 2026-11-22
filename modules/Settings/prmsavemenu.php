<?php

global $adb,$default_charset;

if(isset($_REQUEST['selectedtabColumnsString'])&& $_REQUEST['selectedtabColumnsString']!='')
    $tabids=$_REQUEST['selectedtabColumnsString'];
$tabids=mb_substr($tabids,0,strlen($tabids)-1,$default_charset);
$tabarr=array_filter(explode(';',$tabids));

$del_query='delete from ld_prmparenttabrel';
$adb->pquery($del_query,array());

$query='insert into ld_prmparenttabrel(tabid,sequence,tab_tablename)value';
$value='';
for($i=0;$i<count($tabarr);$i++){
    $index=$i+1;
    $tmptabs=explode(":",$tabarr[$i]);
    $tmptabid=$tmptabs[0];
    if (empty($tmptabid))
        continue;
    $tab_tablename=$tmptabs[1];
    $value .='('.$tmptabid.','.$index.',"'.$tab_tablename.'")'.',';
}
if (!empty($value)) {
    $adb->query($query.mb_substr($value,0,strlen($value)-1,$default_charset));
}
$cachekey = 'cache_getprmmenurelinfo';
unsetCache($cachekey);
ConvertTojsonString(1,array(),"success");


?>