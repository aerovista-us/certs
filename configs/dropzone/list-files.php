<?php
header('Content-Type: application/json');

$uploadDir = "/var/www/html/uploads/";
$files = [];

if (is_dir($uploadDir)) {
    $fileList = scandir($uploadDir);
    
    foreach ($fileList as $file) {
        if ($file !== '.' && $file !== '..') {
            $filePath = $uploadDir . $file;
            if (is_file($filePath)) {
                $files[] = [
                    'name' => $file,
                    'size' => filesize($filePath),
                    'date' => date('Y-m-d H:i:s', filemtime($filePath)),
                    'type' => mime_content_type($filePath)
                ];
            }
        }
    }
}

// Sort by date (newest first)
usort($files, function($a, $b) {
    return strtotime($b['date']) - strtotime($a['date']);
});

echo json_encode($files);
?>
