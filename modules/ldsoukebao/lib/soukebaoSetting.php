<?php
global $current_user,$currentModule;
$mode = $_REQUEST['mode'];

$arr = [];
if($mode == 'importmodule'){
    if(!empty($_REQUEST['importmodule'])){
        setUsersettingByLabel('ldsoukebao','1','soukebaoimportmodule',$_REQUEST['importmodule']);
    }
    $importmodule = getUsersettingByLabel('ldsoukebao','1','soukebaoimportmodule')?:'Accounts';
    $arr['importmodulename'] = getTranstab($importmodule);
}
ConvertTojsonString(1,$arr,'sussess');
?>
