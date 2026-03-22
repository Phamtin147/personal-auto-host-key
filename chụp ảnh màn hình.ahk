#Requires AutoHotkey v2.0
#SingleInstance Force

/*
HƯỚNG DẪN MỚI:
Phím tắt: Ctrl + Shift + S
Script sẽ yêu cầu 2 tham số:
n: Số ảnh chụp mỗi tab (sau mỗi ảnh nhấn sang Phải)
m: Số lượng tab muốn xử lý (sau n ảnh sẽ nhấn Ctrl + W)

Ví dụ: Nếu n=5 và m=3, nó sẽ thực hiện (chụp 5 ảnh + nhấn phải 5 lần -> nhấn Ctrl+W) x 3 lần.
*/

^+s::
{
    ; --- CÀI ĐẶT ---
    PathLuu := A_MyDocuments "\Screenshots"
    if !DirExist(PathLuu)
        DirCreate(PathLuu)

    ; 1. Lấy thông số n (số ảnh mỗi tab)
    ResN := InputBox("Nhập số ảnh muốn chụp mỗi tab (n):", "Cài đặt số ảnh", "w350 h130", "5")
    if ResN.Result = "Cancel"
        return
    n := Integer(ResN.Value)

    ; 2. Lấy thông số m (số tab muốn xử lý)
    ResM := InputBox("Sau khi chụp n ảnh, bạn muốn lặp lại bao nhiêu tab (m):", "Cài đặt số tab", "w350 h130", "1")
    if ResM.Result = "Cancel"
        return
    m := Integer(ResM.Value)

    ; Bắt đầu quy trình
    Loop m ; Lặp lại m tab
    {
        TabHienTai := A_Index ; Lưu vị trí tab đang chạy
        
        Loop n ; Trong mỗi tab, chụp n ảnh
        {
            ; --- Chụp ảnh ---
            Send("{PrintScreen}")
            Sleep(800) 

            ; --- Lưu ảnh ---
            Timestamp := FormatTime(, "yyyyMMdd_HHmmss") "_T" TabHienTai "_A" A_Index
            FileLuu := PathLuu "\Anh_" Timestamp ".png"
            
            PsCommand := "powershell -NoProfile -Command `"Add-Type -AssemblyName System.Windows.Forms, System.Drawing; $img = [Windows.Forms.Clipboard]::GetImage(); if ($img) { $img.Save('" FileLuu "', [System.Drawing.Imaging.ImageFormat]::Png) }`""
            RunWait(PsCommand, , "Hide")
            
            ToolTip("Tab " TabHienTai "/" m "`nẢnh " A_Index "/" n "`nĐã lưu: " FileLuu)

            ; --- Nhấn qua phải ---
            Send("{Right}")
            Sleep(1000) ; Chờ load trang
        }

        ; --- Sau khi đủ n ảnh, nhấn Ctrl + W để tắt tab ---
        Send("^w")
        ToolTip("Đã đóng tab " TabHienTai "/" m)
        Sleep(1500) ; Đợi một chút để trình duyệt chuyển sang tab tiếp theo
    }

    ToolTip("Hoàn thành! Đã xử lý xong " m " tab và dừng script.")
    SetTimer () => ToolTip(), -5000
    MsgBox("Tất cả đã hoàn thành!", "Thông báo", "T2")
}

; Nhấn Esc để dừng script khẩn cấp
Esc::ExitApp
