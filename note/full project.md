Email: admin@nubtkpilot.com
Password: Adminpilot@123456

Get-ChildItem -Path lib,android,pubspec.yaml -Recurse -File -Exclude *.png,*.jpg,*.jpeg,*.webp,*.ttf,*.otf,*.exe,*.dll | Where-Object {$_.FullName -notmatch '\\build\\|\\.dart_tool\\|\\.idea\\|\\.gradle\\'} | ForEach-Object {
    "------------------------------------------------------------"
    "FILE: $($_.FullName.Replace((Get-Location).Path + '\',''))"
    "------------------------------------------------------------"
    Get-Content $_.FullName
    ""
} > full_project_dump.txt