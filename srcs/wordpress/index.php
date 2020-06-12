<?php

echo "<h1>wtf</h1>";
$db_conn = mysqli_connect('wordpress-mysql', 'root', 'hello');
var_dump($db_conn);

$result = mysqli_query($db_conn,"SHOW DATABASES");
while ($row = mysqli_fetch_array($result)) {
	echo $row[0]."<br>";
}

