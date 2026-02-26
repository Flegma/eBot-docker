#!/usr/bin/env php
<?php
/**
 * Patches Symfony 1.4 for PHP 7.4 compatibility.
 * Replaces all deprecated preg_replace /e modifier usages.
 */

$baseDir = $argv[1] ?? 'eBot-CSGO-Web';
$vendorDir = "$baseDir/lib/vendor/symfony/lib";
$patched = 0;
$errors = 0;

// ── sfWebResponse: normalizeHeaderName ──
patchByLine(
    "$vendorDir/response/sfWebResponse.class.php",
    "return preg_replace('/\-(.)/e'",
    '    return implode(\'-\', array_map(function($part) { return ucfirst(strtolower($part)); }, explode(\'-\', strtr(ucfirst(strtolower($name)), \'_\', \'-\'))));'
);

// ── sfCommandManager: argument parsing ──
patchByLine(
    "$vendorDir/command/sfCommandManager.class.php",
    "preg_replace('/(\'|\")(.+?)\\\\1/e'",
    '      $arguments = preg_replace_callback(\'/(\\\'|")(.+?)\\\\1/\', function($m) { return str_replace(\' \', \'=PLACEHOLDER=\', $m[2]); }, $arguments);'
);

// ── sfFormObject: camelize ──
patchByLine(
    "$vendorDir/form/addon/sfFormObject.class.php",
    "return preg_replace(array('#/(.?)#e'",
    '    return preg_replace_callback_array([\'#/(.?)#\' => function($m) { return \'::\'  .strtoupper($m[1]); }, \'/(^|_|-)+(.)/\' => function($m) { return strtoupper($m[2]); }], $text);'
);

echo "\nDone: $patched file(s) patched, $errors error(s).\n";
exit($errors > 0 ? 1 : 0);

/**
 * Finds the line containing $needle and replaces the entire line with $replacement.
 */
function patchByLine(string $file, string $needle, string $replacement)
{
    global $patched, $errors;

    if (!file_exists($file)) {
        echo "File not found (skipping): $file\n";
        return;
    }

    $lines = file($file);
    $found = false;

    foreach ($lines as $i => &$line) {
        if (strpos($line, $needle) !== false) {
            $line = $replacement . "\n";
            $found = true;
            break;
        }
    }
    unset($line);

    if ($found) {
        file_put_contents($file, implode('', $lines));
        echo "Patched: $file\n";
        $patched++;
    } elseif (strpos(file_get_contents($file), 'preg_replace_callback') !== false) {
        echo "Already patched: $file\n";
    } else {
        echo "Error: needle not found in $file\n";
        echo "  Looking for: $needle\n";
        $errors++;
    }
}
