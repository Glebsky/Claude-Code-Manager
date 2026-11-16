$file = 'C:\OSPanel\home\claude_code_manager\claude_code_manager\claude_code_manager.pyw'
$content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$old = "try:`r`n    _ssl_context = ssl.create_default_context()`r`n    _ssl_context.check_hostname = False`r`n    _ssl_context.verify_mode = ssl.CERT_NONE`r`nexcept:`r`n    _ssl_context = ssl._create_unverified_context()"

$new = "try:`r`n    # SEC-01: SSL-верификация включена (по умолчанию). Для HTTP-эндпойнтов без TLS используйте http://`r`n    _ssl_context = ssl.create_default_context()`r`nexcept Exception:`r`n    _ssl_context = ssl.create_default_context()"

if ($content.Contains($old)) {
    $content = $content.Replace($old, $new)
    [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
    Write-Host 'OK: SSL fix applied'
} else {
    Write-Host 'NOT FOUND - checking raw bytes...'
    # Попытка с LF
    $old2 = "try:`n    _ssl_context = ssl.create_default_context()`n    _ssl_context.check_hostname = False`n    _ssl_context.verify_mode = ssl.CERT_NONE`nexcept:`n    _ssl_context = ssl._create_unverified_context()"
    if ($content.Contains($old2)) {
        $new2 = "try:`n    # SEC-01: SSL-верификация включена (по умолчанию). Для HTTP-эндпойнтов без TLS используйте http://`n    _ssl_context = ssl.create_default_context()`nexcept Exception:`n    _ssl_context = ssl.create_default_context()"
        $content = $content.Replace($old2, $new2)
        [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
        Write-Host 'OK: SSL fix applied (LF variant)'
    } else {
        Write-Host 'STILL NOT FOUND'
    }
}
