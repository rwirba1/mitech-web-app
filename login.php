<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    $validCredentials = [
        'admin' => 'admin',
        'student' => 'student'
    ];

    if (isset($validCredentials[$username]) && $validCredentials[$username] === $password) {
        header('Location: welcome.html');
        exit;
    } else {
        header('Location: index.html?error');
        exit;
    }
}
?>

