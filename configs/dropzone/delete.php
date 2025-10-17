<?php
header('Content-Type: application/json');

$uploadDir = "/var/www/html/uploads/";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['filename'])) {
        $filename = basename($input['filename']);
        $filePath = $uploadDir . $filename;
        
        if (file_exists($filePath) && is_file($filePath)) {
            if (unlink($filePath)) {
                echo json_encode(['status' => 'success', 'message' => 'File deleted successfully']);
            } else {
                http_response_code(500);
                echo json_encode(['status' => 'error', 'message' => 'Failed to delete file']);
            }
        } else {
            http_response_code(404);
            echo json_encode(['status' => 'error', 'message' => 'File not found']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'No filename provided']);
    }
} else {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Method not allowed']);
}
?>
