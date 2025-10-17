<?php
// Simple file upload handler for AeroVista Drop Zone

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$uploadDir = '/uploads/';
$maxFileSize = 100 * 1024 * 1024; // 100MB

// Create upload directory if it doesn't exist
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

if (!isset($_FILES['file'])) {
    http_response_code(400);
    echo json_encode(['error' => 'No file uploaded']);
    exit;
}

$file = $_FILES['file'];

// Validate file size
if ($file['size'] > $maxFileSize) {
    http_response_code(413);
    echo json_encode(['error' => 'File too large']);
    exit;
}

// Generate unique filename
$extension = pathinfo($file['name'], PATHINFO_EXTENSION);
$filename = uniqid() . '_' . preg_replace('/[^a-zA-Z0-9._-]/', '_', $file['name']);
$filepath = $uploadDir . $filename;

// Move uploaded file
if (move_uploaded_file($file['tmp_name'], $filepath)) {
    echo json_encode([
        'success' => true,
        'filename' => $filename,
        'original_name' => $file['name'],
        'size' => $file['size'],
        'url' => "https://fileshare.nxcore.tail79107c.ts.net/uploads/{$filename}"
    ]);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Upload failed']);
}
?>
