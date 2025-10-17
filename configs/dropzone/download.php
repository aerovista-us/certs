<?php
$uploadDir = "/var/www/html/uploads/";

if (isset($_GET['file'])) {
    $filename = basename($_GET['file']);
    $filePath = $uploadDir . $filename;
    
    if (file_exists($filePath) && is_file($filePath)) {
        // Set headers for file download
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Content-Length: ' . filesize($filePath));
        header('Cache-Control: no-cache, must-revalidate');
        header('Expires: Sat, 26 Jul 1997 05:00:00 GMT');
        
        // Output the file
        readfile($filePath);
        exit;
    } else {
        http_response_code(404);
        echo "File not found";
    }
} else {
    http_response_code(400);
    echo "No file specified";
}
?>
