<?php
if (isset($_REQUEST['frommodule']) && !empty($_REQUEST['frommodule'])) {
    $currentModule = $_REQUEST['frommodule'];
}
    include globalStatic::$root_directory.'modules/lingdang/DecryptColumn.php';