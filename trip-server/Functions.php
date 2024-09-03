
<?php

function extractRawJSON()
{
    $rawData = file_get_contents('php://input');

    $data = json_decode($rawData, true);
    return $data;
}
?>